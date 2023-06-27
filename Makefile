all: build

.PHONY: build deploy live

build:
	bundle exec nanoc

deploy: build
	bundle exec nanoc deploy

live:
	bundle exec nanoc live -o 0.0.0.0
