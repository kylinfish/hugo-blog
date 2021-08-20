.PHONY: all, deploy, run, clean, init

all: clean
	(git pull)
	(hugo)

deploy: clean
	(hugo)
	(cp robots.txt ./public/)
	(cp ads.txt ./public/)
	(firebase deploy)

run: clean
	(hugo serve --disableFastRender -D)

clean:
	(rm -rf public)

init:
	git clone https://github.com/dillonzq/LoveIt.git themes/LoveIt
