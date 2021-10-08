extends Node
# Monte Carlo Tree Search 

export var calculation_time = 1  # sec 
export var memory = 2  # umm... MB  :v
export var BOT_TURN: int
export var exploration_factor = 1 


onready var no_of_simulations = 0 
onready var root: State

onready var debugging = false

const cost = Globals.cost

enum Cell{
	Soil
	Grass
	Rock
	Flower_1
	Flower_2
}

func initialise_root(map: Array, money: Array, have_first_turn: bool):
	BOT_TURN = int(not have_first_turn)  # 0 --> first turn,  1 --> 2nd turn
	
	root = State.new() 
	root.state = map.duplicate(true)
	root.money = money.duplicate()
	root.current_turn = 0
	root.turns_left = Globals.max_turns
	
	# all children are non_expanded by default 
	for i in range(Globals.BOARD_SIZE):
		for j in range(Globals.BOARD_SIZE):
			root.non_expanded_children.append([i, j]) 
	
	root.non_expanded_children.shuffle()



class State:
	var state: Array 
	var parent = null 
	var move_made: Vector2
	var money = [0, 0] 
	var out_of_money = false 
	var current_turn: int  # who played just now
	var my_flower
	var opponent_flower
	
	var children = [] 
	var non_expanded_children = [] 
	
	var no_of_children = Globals.BOARD_SIZE * Globals.BOARD_SIZE
	var turns_left: int
	var wins = 0.0
	var plays = 0.0
	 
	
	func _init(prev_state: State = null, x = null, y = null, just_for_simulation = true):
		if prev_state == null:
			# gonna initialise all variable separately.  :'v
			return 
		parent = prev_state
		move_made = Vector2(x, y) 
		current_turn = 1 - prev_state.current_turn
		turns_left = prev_state.turns_left - 1
		
		state = prev_state.state.duplicate(true)
		money = prev_state.money.duplicate()
		money[current_turn] -= cost[state[x][y]]
		if money[current_turn] < 0:
			out_of_money = true
		
		my_flower = Cell.Flower_1
		opponent_flower = Cell.Flower_2
		if current_turn:
			my_flower = Cell.Flower_2
			opponent_flower = Cell.Flower_1
		
		state[x][y] = my_flower
		
		check_lineup(Vector2(x, y))
		
		# print(current_turn, "'s flower is: ", flower)
		
		if not just_for_simulation:
			# initialises  no_of_children  and  non_expanded_children 
			for i in range(Globals.BOARD_SIZE):
				for j in range(Globals.BOARD_SIZE):
					if state[i][j] == opponent_flower:
						no_of_children -= 1 
					else:
						non_expanded_children.append([i, j])
			
			non_expanded_children.shuffle()

	func check_lineup(cell_pos):
		var all_lineups = [cell_pos] 
		
		for direction in [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, -1)]:
			var lineup = [] 
			
			for jump_direction in [1, -1]:
				var i = jump_direction
				while is_similar_flower(cell_pos + i * direction):
					lineup.append(cell_pos + i * direction)
					i += jump_direction
				
			if len(lineup) >= 3:  # plus cell_pos
				all_lineups += lineup
		
		if len(all_lineups) == 1:  # no lineup
			return 
		
		money[current_turn] += find_money_value(len(all_lineups))
		
		for pos in all_lineups:
			state[pos.x][pos.y] = Cell.Grass
	
	
	func is_similar_flower(cell_pos):
		if 0 <= cell_pos.x and cell_pos.x < Globals.BOARD_SIZE:
			if 0 <= cell_pos.y and cell_pos.y < Globals.BOARD_SIZE:
				if state[cell_pos.x][cell_pos.y] == my_flower:
					return true 
		return false 
		
	func find_money_value(n):
		# sum of first n fibbonacci numbers
		var x = 0 
		var y = 1
		
		var sum = 0 
		for i in range(n):
			sum += y
			y += x 
			x = y - x 
		
		return sum 
	
	func find_random_child():
		var x = randi() % Globals.BOARD_SIZE
		var y = randi() % Globals.BOARD_SIZE
		
		if state[x][y] == opponent_flower: 
			return find_random_child()
		
		return State.new(self, x, y)
	
	func is_leaf():
		if out_of_money:
			return true 
		
		if money[0] < 0 or money[1] < 0:
			return true
		if turns_left == 0:
			return true
			
		return false 
	
	func find_winner():
		if out_of_money:
			return 1 - current_turn
		if money[0] > money[1]:
			return 0 
		if money[1] > money[0]:
			return 1
			
		return 0.5  # draw 
	
	
	func set_reward(winner: int):
		plays += 1 
		
		if winner == 0.5:
			wins += 0.5
		elif winner == current_turn:
			wins += 1


func simulate(node: State):
	if node.is_leaf():
		return node.find_winner()
	
	var current_state = node 
	while true:
		var random_child = current_state.find_random_child()
		if debugging:
			print(random_child.current_turn, ' played ', random_child.move_made)
			print(random_child.turns_left, ' turns left')
		if random_child.is_leaf():
			if debugging:
				print('ending the simulation') 
			return random_child.find_winner()  
		
		current_state = random_child 



func backpropagate(node: State, winner: int):
	# player number (turn + 1) got reward amount of reward
	# winner in [0, 0.5, 1]
	assert(winner in [0, 0.5, 1])
	
	# var current_node = node 
	
	while node != null:
		node.set_reward(winner) 
		node = node.parent


func uct_formula(node: State):
	if node.plays == 0:
		return INF
		
	var exploration = sqrt(log(node.parent.plays) / node.plays)
	var exploitation = node.wins / node.plays 
	
	return exploitation + exploration_factor * exploration

func uct_select(node):
	var temp: State
	var temp_value
	var value 
	for child in node.children:
		if temp == null:
			temp = child 
			temp_value = uct_formula(child)
		else:
			value = uct_formula(child)
			if value > temp_value:
				temp = child 
				temp_value = value 
	
	return temp 


func select_node():
	var node: State = root 
	
	while (not node.is_leaf()) and len(node.children) == node.no_of_children:  # max children
		node = uct_select(node)
	
	return node 

func expand(node):
	# adds a random unexpanded node on node node.  :v
	if node.is_leaf():
		return node 
	
	var move = node.non_expanded_children.pop_back() 
	
	var new_node = State.new(node, move[0], move[1], false)
	node.children.append(new_node)
	
	return new_node


func run_simulation():
	var node = select_node()
	
	node = expand(node)
	
	var winner = simulate(node)
	
	backpropagate(node, winner) 
	
	no_of_simulations += 1 

func free_old_nodes(old_root):
	##  DOES NOT WORK  !!
	# recursive function to free the tree
	if not old_root.children:
		old_root.free() 
	
	for child in old_root.children:
		free_old_nodes(child)
	
	old_root.free() 


func change_root(new_root):
	# assert(new_root in root.children)
	
	# root.children.erase(new_root)
	# free_old_nodes(root)
	root = new_root 
	root.parent = null 

func play_move(move: Vector2):
	for child in root.children:
		if child.move_made == move:
			change_root(child)
			return 
	# not expanded yet ? 
	if [int(move.x), int(move.y)] in root.non_expanded_children:
		print('move was not expanded.')
		change_root(State.new(root, int(move.x), int(move.y), false)) 
	else:
		print("Huhh.. unable to play the move ", move)
	

func find_move_to_play():
	# considers that it's bot's turn 
	var best = null  
	
	# print(no_of_simulations)
	
	
	if not root.children:
		best = root.find_random_child()
		print("playing a random move")
		play_move(best.move_made)
		return best.move_made 

	for child in root.children:
		if best == null:
			best = child 
		# elif child.wins / child.plays > best.wins / best.plays:
		elif child.plays > best.plays:
			# print(child.wins / child.plays, ' is better than ', best.wins / best.plays)
			best = child 
	
	print("Probability that you will patheticly lose = ", 100 * best.wins / best.plays, '%')
	# print(best.wins, '  ', best.plays)
	play_move(best.move_made)
	return best.move_made

func _process(delta):
	if delta < 0.02:  # don't ask what I am doing.  :v
		for i in range(20):
			run_simulation()
