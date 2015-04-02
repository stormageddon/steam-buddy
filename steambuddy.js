var request = require('request');

var hostUrl = 'http://powerful-cliffs-9562.herokuapp.com';
var hostPort = '80';
var hostPath = hostUrl + ':' + hostPort;
var sessionToken = 'ba716392dca54875977ef32f11a41165174f0dd61c13a79a2ec7bf59dd44509387b2dc8c1ab127ca79e250153f08cb52';

var io = require('socket.io')();

//var ioClient = require('socket.io-client')(hostPath, {query: "token="+sessionToken});
var ioClient = require('socket.io-client')(hostPath, {timeout: 5000});
//io.on('connection', function(socket){
//  console.log('CONNECTED!');
//});
//io.listen(3000);

this.socket = null;

//var socket = io.connect('http://yourhostname.com/');
//connectToHost:BASE_URL onPort:BASE_PORT withParams:@{@"token": [CHUser currentUser].sessionToken}

this.connect = function(token) {
  console.log('Connecting to Socket.io!');
  //this.socket = io.use('/', { query: 'token=' + token });
  this.socket = io.use(hostUrl + ':' + hostPort);

  this.socket.on('connect', function() {
    console.log('Connected!');
    sendMessage();
  });

  this.socket.on('error', function(err) {
    console.log('error:', err);
  });

  this.socket.on('event', function(data) {
    console.log('event:', data);
  });


};

//this.connect(token);

//ioClient.use(hostPath, {query: 'token=' + sessionToken});

ioClient.on('connect', function() {
  console.log('connected!');
});

ioClient.on('connect_error', function(err) {
  if (err.description) {
    console.log('descriptive error:', err.description);
  }
  else {
    console.log('error :(', err);
  }
});

ioClient.on('error', function(data){console.log('event:', data);});


/*
 API Key: 9186ADF14E6553A2257FAC4856F822EA
 Castiel id: 76561198064286306
*/

var API_KEY = '9186ADF14E6553A2257FAC4856F822EA';
var TEST_ID = '76561198081408345'//ethan: '76561198024956371'; // me: '76561198081408345';//'76561198064286306';
var TEST_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=9186ADF14E6553A2257FAC4856F822EA&steamids='+TEST_ID;
var sendMessage = function() {
  request(TEST_URL, function (error, response, body) {
    if (!error && response.statusCode == 200) {
      var parsedResult = JSON.parse(body);
      var player = parsedResult.response.players[0];
      var playerName = player.personaname;
      var game = player.gameextrainfo;
      console.log('%s is playing %s',playerName,game);
      if( game ) {
	if( this.socket ) {
	  notify(playerName + ' is playing ' + game + '! Go join him!');
	}
	else {
	  console.log('not connected');
	}
      }
    }
  });
}

var notify = function(message) {
  this.socket.emit('message', message);
}

/*  this.send = function(message) {
    if (!this.isConnected()) {
      console.log('Error! You are not connected to socket.io!');
      return;
    }
    this.socket.emit('message', message);
  };*/


