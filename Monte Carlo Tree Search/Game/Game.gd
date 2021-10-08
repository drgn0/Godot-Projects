extends Node2D

signal next_turn
signal player_lose(player_number)
signal increase_coins(player_number, amount)
signal decrease_coins(player_number, amount) 
signal player_played_move(move) 

export var player_has_first_turn: bool = false

onready var PLAYER_TURN = int(not player_has_first_turn)
onready var turn: int = PLAYER_TURN  # 0 or 1  represents player number
onready var board = $Board
onready var bot = $Bot
 

onready var turns_left = Globals.max_turns
onready var players_money = Globals.money.duplicate() 

func _init():
	randomize() 

func _ready():
	bot.initialise_root(board.map,  players_money, not player_has_first_turn)
	
	
func _input(event):
	if event.is_action_released("mouse_click"):
		if Globals.single_player or turn == PLAYER_TURN:
			board.try_playing(turn)
		else:
			# bot turn  !! 
			var bot_play = bot.find_move_to_play()
			board.play_turn(turn, bot_play)
	
	if event.is_action_released("right_click"):
		var cell_pos = board.find_cell_pos()
		if cell_pos == null:
			return 
		
		var node = null
		for state in bot.root.children:
			if state.move_made == cell_pos:
				if node:
					print("Huhh.. more than one  ??") 
				node = state 
		
		if node == null:
			print("Huhh.. node not found ..  :v")
		else:
			print('wins and plays:  ', node.wins, '  ', node.plays)
		


func end_game():
	if players_money[0] == players_money[1]:
		print("wow, it's a draw.")
	elif players_money[PLAYER_TURN] > players_money[1 - PLAYER_TURN]:
		print("Woah.. you won. ")
	else:
		print("You Lose  !!\nBow before the great AI..!!") 
	
	
	yield(get_tree().create_timer(2), 'timeout')
	get_tree().quit() 

func train_bot():
	for i in range(4000):
		bot.run_simulation()
	
func _on_Game_next_turn():
	turn = 1 - turn 
	turns_left -= 1 
	if turns_left == 0:
		end_game()
	$turns_left.text = str(turns_left)
	
	return 

func find_value_of_coins(n):
	# sum of n fibbonacci numbers 
	var sum = 0
	
	var x = 0 
	var y = 1
 
	for i in range(n):
		sum += y
		y += x 
		x = y - x 
	
	return sum 

func _on_Game_increase_coins(player_number, amount):
	players_money[player_number] += find_value_of_coins(amount)
	$Money.get_child(player_number).text = str(players_money[player_number])

func _on_Game_decrease_coins(player_number, amount):
	players_money[player_number] -= amount 
	if players_money[player_number] < 0:
		emit_signal("player_lose", player_number)
	else:
		$Money.get_child(player_number).text = str(players_money[player_number])



func _on_Game_player_lose(player_number):
	print("Player ", player_number + 1, " don't have sufficient money") 
	get_tree().quit() 


func _on_Game_player_played_move(move):
	bot.play_move(move)
