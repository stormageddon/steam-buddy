var http = require('http');


/*
 API Key: 9186ADF14E6553A2257FAC4856F822EA
 Castiel id: 76561198064286306
*/

var API_KEY = '9186ADF14E6553A2257FAC4856F822EA';
var TEST_ID = '76561198081408345';//'76561198064286306';
var TEST_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=9186ADF14E6553A2257FAC4856F822EA&steamids='+TEST_ID;

var postData = JSON.stringify({'msg' : 'hello world!'});

http.get(TEST_URL, function(res, data) {
  res.setEncoding('utf8');
  var body = 'body';
  if (res.statusCode === 200) {
    res.on('data', function(chunk) {
      body += chunk;
    });
    res.on('end', function() {
      console.log('body:', body['body']);
    });
  }
}).on('error', function(e) {
  console.log("Got error: " + e.message);
});