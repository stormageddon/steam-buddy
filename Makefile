compile:
	./node_modules/coffee-script/bin/coffee -c ./lib/js/steambuddy.coffee
	./node_modules/coffee-script/bin/coffee -c ./lib/js/parser.coffee

run:
	$(MAKE) compile
	node ./lib/js/steambuddy.js
