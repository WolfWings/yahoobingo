io = require "socket.io-client" if exports? && this.exports != exports
socket = io.connect "ws://yahoobingo.herokuapp.com"
socket.on "connect", ->
	result = "playing"

	scores = {}
	card = 0

	socket.on "card", (data) ->
		bit = 0
		for letter, balls of data.slots
			console.log letter, balls
			for ball in balls
				scores["#{letter}#{ball}"] = bit
				bit++

	socket.on "number", (data) ->
		if scores[data]?
			bit = scores[data]
			card |= (1 << bit)
			column = 0x108421 << (bit % 5)
			row = 0x1F << (Math.floor(bit / 5) * 5)

			console.log bit % 5, Math.floor(bit / 5), data, card.toString 2

			socket.emit "bingo" if ((card & column) == column)
			socket.emit "bingo" if ((card & row) == row)
			socket.emit "bingo" if ((card & 0x1041041) == 0x1041041)
			socket.emit "bingo" if ((card & 0x111110) == 0x111110)
		else
			console.log data

	socket.on "win", ->
		result = "won"

	socket.on "lose", ->
		result = "lost"

	socket.on "disconnect", ->
		console.log "You have #{result}."
		process.exit()

	socket.emit "register",
		name: "WolfWings"
		email: "wolfwings@wolfwings.us"
