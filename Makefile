.PHONY: all, deploy, deploy-worker, run, clean, init

all: clean
	(git pull)
	(hugo)

deploy: clean
	(hugo)
	(cp robots.txt ./public/)
	(cp ads.txt ./public/)
	(firebase deploy)

deploy-worker:
	(cd workers && wrangler deploy yahoo-proxy.worker.js --name yahoo-proxy)

run: clean
	(hugo serve --disableFastRender -D)

clean:
	(rm -rf public)

init:
	git clone https://github.com/dillonzq/LoveIt.git themes/LoveIt
