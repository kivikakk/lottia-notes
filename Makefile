all: build

.PHONY: build deploy live

build:
	bundle exec nanoc

deploy: build
	rsync -av --delete output/ ~/g/vyxos/sites/lottia.net/notes/

live:
	bundle exec nanoc live -o 0.0.0.0
