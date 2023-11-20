default: test

test:
	bundle exec rake
	CI=true bundle exec rake

lint:
	bundle exec rubocop

release: test lint
	git status
	RELEASING_RUNGER=true gem release -t
	git push
	git push --tags
