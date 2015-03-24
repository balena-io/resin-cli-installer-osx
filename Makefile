all: build/resin-cli.dmg

NODE_VERSION=0.12.0
NODE_PACKAGE=node-v$(NODE_VERSION)-darwin-x64
RESIN_VERSION=0.0.1

build/node.tar.gz:
	mkdir -p `dirname $@`
	curl "http://nodejs.org/dist/v$(NODE_VERSION)/$(NODE_PACKAGE).tar.gz" -o $@

build/node: build/node.tar.gz
	mkdir -p $@
	tar fxz $< -C `dirname $@`
	cp -rf `dirname $@`/$(NODE_PACKAGE)/* $@

build/node.pkg: build/node
	pkgbuild --root $< \
		--identifier io.resin.node \
		--scripts scripts \
		--version $(NODE_VERSION) \
		--ownership recommended \
		$@

build/resin-cli-setup.pkg: build/node.pkg distribution.xml
	productbuild --distribution $(word 2, $^) \
		--resources resources \
		--package-path `dirname $<` \
		--version $(RESIN_VERSION) \
		$@

build/README.pdf:
	curl "http://gitprint.com/resin-io/resin-cli/?download" -o $@

build/resin-cli.dmg: appdmg.json build/resin-cli-setup.pkg build/README.pdf
	rm -f $@
	appdmg $< $@

clean:
	rm -rf build/
