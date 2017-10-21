#
all: clean
	(git pull)
	(gulp)
	(cd themes/readable && make)
	(hugo)

deploy: clean
	(hugo)
	(gulp)
	(cp robots.txt ./public/robots.txt)
	(cp sitemap.xml ./public/sitemap.xml)
	firebase deploy

run: clean
	(hugo)
	(hugo server --theme=readable --buildDrafts)

clean:
	(rm -rf public)
