all: build

.PHONY: build live

build:
	bundle exec nanoc
	rsync -av output/ ../kivikakk.ee/notes/

live:
	bundle exec nanoc live -o 0.0.0.0
