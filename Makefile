compile:
	./node_modules/coffee-script/bin/coffee --compile --output dist/ lib/

run:
	$(MAKE) compile
	node --harmony dist/server.js
