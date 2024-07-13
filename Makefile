all: build

.PHONY: build live

build:
	bundle exec nanoc

live:
	bundle exec nanoc live -o 0.0.0.0
