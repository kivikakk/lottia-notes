all: deploy

.PHONY: deploy build live

deploy: build
	bundle exec nanoc deploy

build:
	bundle exec nanoc

live:
	bundle exec nanoc live
