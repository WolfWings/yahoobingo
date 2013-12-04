var Bingo = require('./lib/bingo');
var player = new Bingo.Client();
var io = require('socket.io-client');
var callback = (function(bit, ball, state) { console.log(bit, ball, state); });
player.ai(callback, io);
