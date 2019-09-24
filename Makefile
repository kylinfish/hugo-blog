#
all: clean style
	(git pull)
	(hugo)
	(gulp build)
	(cd themes/hugo-readable && make style)

deploy: clean style
	(npm install)
	(hugo)
	(gulp build)
	(cp robots.txt ./public/robots.txt)
	(cp sitemap.xml ./public/sitemap.xml)
	firebase deploy --only hosting:kylinyu-blog-site

run: clean
	(hugo)
	(hugo server --theme=hugo-readable --buildDrafts)

clean:
	(rm -rf public)

style:
	(cd themes/hugo-readable && make style)

init:
	(mkdir themes)
	(cd themes && git clone git@github.com:kylinfish/hugo-readable.git)
	(make)
