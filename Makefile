#
all:
	(git pull)

deploy:
	(rm -rf public)
	(hugo)
	(cp robots.txt ./public/robots.txt)
	firebase deploy

dev:
	(rm -rf public)
	(hugo)
	(hugo server --theme=readable --buildDrafts)
