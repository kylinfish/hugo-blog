#
all: clean
	(git pull)
	(hugo)

deploy: clean
	(hugo)
	firebase deploy

run: clean
	(hugo serve --disableFastRender -D)

clean:
	(rm -rf public)

init:
	git clone https://github.com/dillonzq/LoveIt.git themes/LoveIt
