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
	hugo server --theme=hugo-win-bs-theme --buildDrafts
