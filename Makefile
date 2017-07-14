#
all:
	(git pull)

deploy:
	(rm -rf public)
	(hugo)
	(cp ./public/post/index.html ./public/index.html)
	(cp robots.txt ./public/)
	firebase deploy

dev:
	(rm -rf public)
	(hugo)
	(hugo server --theme=readable --buildDrafts)
