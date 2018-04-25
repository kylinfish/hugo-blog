#
all: clean style
	(git pull)
	(hugo)
	(gulp)
	(cd themes/hugo-readable && make)

deploy: clean style
	(hugo)
	(gulp)
	(cp robots.txt ./public/robots.txt)
	(cp sitemap.xml ./public/sitemap.xml)
	firebase deploy

run: clean
	(hugo)
	(hugo server --theme=hugo-readable --buildDrafts)

clean:
	(rm -rf public)

style:
	(cd themes/hugo-readable && make style)
