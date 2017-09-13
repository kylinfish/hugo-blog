#
all:
	(git pull)
	(rm -rf public)
	(hugo)

deploy:
	(rm -rf public)
	(hugo)
	(gulp)
	(cp robots.txt ./public/robots.txt)
	firebase deploy

run:
	(rm -rf public)
	(hugo)
	(hugo server --theme=readable --buildDrafts)
