#
all: clean
	(git pull)
	(hugo)

deploy: clean
	(hugo)
	(gulp)
	(cp robots.txt ./public/robots.txt)
	firebase deploy

run: clean
	(hugo)
	(hugo server --theme=readable --buildDrafts)

clean:
	(rm -rf public)
