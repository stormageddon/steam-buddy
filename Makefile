compile:
	./node_modules/coffee-script/bin/coffee -c ./lib/js/steambuddy.coffee
	./node_modules/coffee-script/bin/coffee -c ./lib/js/parser.coffee

run:
	make compile
	SLACK_TOKEN=$(SLACK_KEY) node ./lib/js/steambuddy.js
