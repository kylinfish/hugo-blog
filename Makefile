#
all:
	git pull

deploy:
	(cp robots.txt ./public/)
	firebase deploy

