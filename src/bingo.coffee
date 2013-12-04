ai = (callback, io) ->
	socket = io.connect "ws://yahoobingo.herokuapp.com"

	state = "initializing"
	scores = {}
	card = 0

	win = ->
		return unless state = "playing"
		socket.emit "bingo"
		state = "calling bingo"
		callback "result", "BINGO!?", ""

	socket.on "win", ->
		state = "won"

	socket.on "lose", ->
		state = "lost"

	socket.on "disconnect", ->
		callback "result", state, "hit"
		process.exit() if process? and process.exit?

	socket.on "card", (data) ->
		state = "playing"
		scores = {}
		card = 0
		bit = 0
		for letter, balls of data.slots
			for ball in balls
				data = "#{letter}#{ball}"
				callback bit, data, ""
				scores[data] = bit
				bit++

	socket.on "number", (data) ->
		unless scores[data]?
			callback -1, data, ""
			return

		bit = scores[data]
		callback bit, data, "hit"

		card |= (1 << bit)

		win() if ((card & 0x1041041) == 0x1041041)
		win() if ((card & 0x111110) == 0x111110)

		row = 0x1F << (Math.floor(bit / 5) * 5)
		win() if ((card & row) == row)

		column = 0x108421 << (bit % 5)
		win() if ((card & column) == column)

	socket.on "connect", ->
		socket.emit "register",
			name: "WolfWings"
			email: "wolfwings@wolfwings.us"
			url: "https://github.com/WolfWings/yahoobingo/"

Bingo = exports? and exports or @Bingo = {}

class Bingo.Client
	ai: ai
