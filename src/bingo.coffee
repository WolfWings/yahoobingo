ai = (callback, io) ->
	socket = io.connect "ws://yahoobingo.herokuapp.com"

	masks = {}
	masks["\\"] = parseInt ['10000', '01000', '00100', '00010', '00001'].join(""), 2
	masks["/"]  = parseInt ['00001', '00010', '00100', '01000', '10000'].join(""), 2
	masks["|"]  = parseInt ['00001', '00001', '00001', '00001', '00001'].join(""), 2
	masks["-"]  = parseInt ['00000', '00000', '00000', '00000', '11111'].join(""), 2

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

		win() if ((card & masks["\\"]) == masks["\\"])
		win() if ((card & masks["/"]) == masks["/"])

		row = masks["-"] << (Math.floor(bit / 5) * 5)
		win() if ((card & row) == row)

		column = masks["|"] << (bit % 5)
		win() if ((card & column) == column)

	socket.on "connect", ->
		socket.emit "register",
			name: "WolfWings"
			email: "wolfwings@wolfwings.us"
			url: "https://github.com/WolfWings/yahoobingo/"

Bingo = exports? and exports or @Bingo = {}

class Bingo.Client
	ai: ai
