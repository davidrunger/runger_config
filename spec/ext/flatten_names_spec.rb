# frozen_string_literal: true

require 'spec_helper'

describe Runger::Ext::FlattenNames do
  using Runger::Ext::FlattenNames

  describe '#flatten_names' do
    specify do
      expect({ a: %i[b c], d: [:x, { y: { t: [:r] } }] }.flatten_names).to eq(
        %i[
          a.b
          a.c
          d.x
          d.y.t.r
        ],
      )
    end

    specify do
      expect({ a: [], d: { e: [] } }.flatten_names).to eq(
        %i[
          a
          d.e
        ],
      )
    end
  end
end
