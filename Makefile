#
all: clean style
	(git pull)
	(hugo)
	(gulp)
	(cd themes/readable && make)

deploy: clean style
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

style:
	(cd themes/readable && make style)
