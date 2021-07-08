#
all: clean
	(git pull)
	(hugo)

deploy: clean
	(npm install)
	(hugo)
	firebase deploy

run: clean
	(hugo serve --disableFastRender)

clean:
	(rm -rf public)

init:
	(cd themes && git clone https://github.com/dillonzq/LoveIt.git themes/LoveIt
