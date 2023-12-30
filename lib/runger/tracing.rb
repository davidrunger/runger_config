# frozen_string_literal: true

# Provides method to trace values association
module Runger::Tracing
  using Runger::Ext::DeepDup

  using(Module.new do
    refine Thread::Backtrace::Location do
      def path_lineno = "#{path}:#{lineno}"
    end
  end)

  class Trace
    UNDEF = Object.new

    attr_reader :type, :value, :source

    def initialize(type = :trace, value = UNDEF, **source)
      @type = type
      @source = source
      @value = (value == UNDEF) ? Hash.new { |h, k| h[k] = Trace.new(:trace) } : value
    end

    def dig(...)
      value.dig(...)
    end

    def record_value(val, *path, **options)
      key = path.pop
      trace =
        if val.is_a?(Hash)
          Trace.new.tap { _1.merge_values(val, **options) }
        else
          Trace.new(:value, val, **options)
        end

      target_trace = path.empty? ? self : value.dig(*path)
      target_trace.record_key(key.to_s, trace)

      val
    end

    def merge_values(hash, **options)
      return hash unless hash

      hash.each do |key, val|
        if val.is_a?(Hash)
          value[key.to_s].merge_values(val, **options)
        else
          value[key.to_s] = Trace.new(:value, val, **options)
        end
      end

      hash
    end

    def record_key(key, key_trace)
      @value = Hash.new { |h, k| h[k] = Trace.new(:trace) } unless value.is_a?(::Hash)

      value[key] = key_trace
    end

    def merge!(another_trace)
      unless trace?
        raise(ArgumentError,
          "You can only merge into a :trace type, and this is :#{type}")
      end
      unless another_trace.trace?
        raise(ArgumentError,
          "You can only merge a :trace type, but trying :#{type}")
      end

      another_trace.value.each do |key, sub_trace|
        if sub_trace.trace?
          value[key].merge!(sub_trace)
        else
          value[key] = sub_trace
        end
      end
    end

    def keep_if(...)
      raise(ArgumentError, "You can only filter :trace type, and this is :#{type}") unless trace?

      value.keep_if(...)
    end

    def clear = value.clear

    def trace? = type == :trace

    def to_h
      if trace?
        value.transform_values(&:to_h).tap { _1.default_proc = nil }
      else
        { value:, source: }
      end
    end

    def dup = self.class.new(type, value.dup, **source)

    def pretty_print(q)
      if trace?
        q.nest(2) do
          q.breakable('')
          q.seplist(value, nil, :each) do |k, v|
            q.group do
              q.text k
              q.text ' =>'
              if v.trace?
                q.text ' { '
                q.pp(v)
                q.breakable(' ')
                q.text '}'
              else
                q.breakable(' ')
                q.pp(v)
              end
            end
          end
        end
      else
        q.pp(value)
        q.group(0, ' (', ')') do
          q.seplist(source, lambda { q.breakable(' ') }, :each) do |k, v|
            q.group do
              q.text k.to_s
              q.text '='
              q.text v.to_s
            end
          end
        end
      end
    end
  end

  class << self
    def capture
      unless ::Runger::Settings.tracing_enabled
        yield
        return
      end

      trace = Trace.new
      trace_stack.push(trace)
      yield
      trace_stack.last
    ensure
      trace_stack.pop
    end

    def trace_stack
      (Thread.current[:__runger__trace_stack__] ||= [])
    end

    def current_trace = trace_stack.last

    alias tracing? current_trace

    def source_stack
      (Thread.current[:__runger__trace_source_stack__] ||= [])
    end

    def current_trace_source
      source_stack.last || accessor_source(caller_locations(2, 1).first)
    end

    def with_trace_source(src)
      source_stack << src
      yield
    ensure
      source_stack.pop
    end

    private

    def accessor_source(location)
      { type: :accessor, called_from: location.path_lineno }
    end
  end

  module_function

  def trace!(type, *path, **options)
    return yield unless ::Runger::Tracing.tracing?

    val = yield
    if val.is_a?(Hash)
      ::Runger::Tracing.current_trace.merge_values(val, type:, **options)
    elsif !path.empty?
      ::Runger::Tracing.current_trace.record_value(val, *path, type:, **options)
    end
    val
  end
end
