compile:
	./node_modules/coffee-script/bin/coffee --compile --output dist/ lib/

run:
	$(MAKE) compile
	PLAYER_SUMMARY_URL='http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=' \
	node ./dist/js/steambuddy.js
