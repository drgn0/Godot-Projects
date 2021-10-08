extends Node2D

const flower_1_texture = preload("res://assets/black.png")
const flower_2_texture = preload("res://assets/pink.png")
const coin_texture = preload("res://assets/coin.png")


const SOIL_COLOR = Color(140, 40, 0) / 256
const GRASS_COLOR = Color(0, 0.5, 0)

const cost = Globals.cost 

var map: Array
var map_of_sprites: Array  # contains references of sprites placed  (Rock or Flower)
var has_grass: Array 

onready var game = get_parent()

enum Cell{
	Soil
	Grass
	Rock
	Flower_1
	Flower_2
}


func draw_board():
	var line_color = Color(1, 1, 1, 0.1)
	var line_width = 1
	
	for i in range(1, Globals.BOARD_SIZE):
		# horizontal lines
		draw_line(Vector2(0, i) * Globals.CELL_SIZE, Vector2(Globals.BOARD_SIZE, i) * Globals.CELL_SIZE, line_color, line_width)
		
		# vertical lines
		draw_line(Vector2(i, 0) * Globals.CELL_SIZE, Vector2(i, Globals.BOARD_SIZE) * Globals.CELL_SIZE, line_color, line_width) 
	


func _draw():
	draw_board() 


func _ready():
	$BackGround.rect_size = Vector2(1, 1) * Globals.BOARD_SIZE * Globals.CELL_SIZE
	make_map() 


func to_pixels(cell_position: Vector2):
	return cell_position * Globals.CELL_SIZE


func make_map():
	## var rock_sprite = preload("res://assets/stones.png")
	
	# initialising the map 
	map = [] 
	map_of_sprites = [] 
	has_grass = [] 
	for x in range(Globals.BOARD_SIZE):
		map.append([])
		map_of_sprites.append([])
		has_grass.append([])
		for y in range(Globals.BOARD_SIZE):
			map[-1].append(Cell.Soil)
			map_of_sprites[-1].append(null)
			has_grass[-1].append(false)
	
	
	# placing rocks
	var rock_texture = load("res://assets/stones.png")
	var no_of_rocks = 2 + randi() % 4
	
	no_of_rocks = 0 
	
	
	var i = 0
	while i < no_of_rocks:
		var x = randi() % Globals.BOARD_SIZE
		var y = randi() % Globals.BOARD_SIZE
		
		if map[x][y] == Cell.Soil:
			place_sprite(x, y, rock_texture)
			map[x][y] = Cell.Rock
			i += 1



func place_grass(x, y):
	if has_grass[x][y]:
		return 
	has_grass[x][y] = true
	
	var color_rect = ColorRect.new()
	color_rect.color = GRASS_COLOR
	color_rect.rect_position = to_pixels(Vector2(x, y))
	color_rect.rect_size = Vector2(1, 1) * Globals.CELL_SIZE
	
	# map_of_sprites[x][y] = color_rect  # I don't have to remove grass.  :3
	add_child(color_rect) 


func place_sprite(x, y, texture: Texture, update_map: bool = true):
	var sprite = Sprite.new() 
	sprite.texture = texture
	sprite.centered = false 
	sprite.position = to_pixels(Vector2(x, y))
	
	add_child(sprite) 
	
	if map_of_sprites[x][y] != null:
		map_of_sprites[x][y].queue_free() 
		map_of_sprites[x][y] = null
	
	if update_map:
		map_of_sprites[x][y] = sprite
	else:
		# special case for coins  :v
		return sprite 


func find_cell_pos():
	var cell_pos = (get_local_mouse_position() / Globals.CELL_SIZE).floor() 
	if 0 <= cell_pos.x and cell_pos.x < Globals.BOARD_SIZE:
		if 0 <= cell_pos.y and cell_pos.y < Globals.BOARD_SIZE:
			return cell_pos
	
	return null


func play_turn(player_number, cell_pos):
	# considering that the move is valid
	place_grass(cell_pos.x, cell_pos.y)
	place_flower(player_number, cell_pos.x, cell_pos.y)
	check_lineup(player_number, cell_pos)
	game.emit_signal("next_turn")


func try_playing(player_number: int):
	var cell_pos = find_cell_pos()
	if cell_pos != null:  # is valid play
		play_turn(player_number, cell_pos)
		if not Globals.single_player:
			game.emit_signal("player_played_move", cell_pos)



func place_flower(player_number: int, x, y):
	game.emit_signal("decrease_coins", player_number, cost[map[x][y]])
	if player_number == 0:
		place_sprite(x, y, flower_1_texture)
		map[x][y] = Cell.Flower_1
	else:
		place_sprite(x, y, flower_2_texture)
		map[x][y] = Cell.Flower_2


func is_same_flower(cell_pos: Vector2, flower):
	if 0 <= cell_pos.x and cell_pos.x < Globals.BOARD_SIZE:
		if 0 <= cell_pos.y and cell_pos.y < Globals.BOARD_SIZE:
			if map[cell_pos.x][cell_pos.y] == flower:
				return true
	return false 


func check_lineup(player_number, cell_just_placed: Vector2):
	# check whether player player_number just formed a lineup on cell_just_placed
	var all_lineup_cells = [cell_just_placed] 
	
	var flower = Cell.Flower_1
	if player_number == 1:
		flower = Cell.Flower_2
	
	for direction in [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, -1)]:
		var lineup_cells = [] 
		
		for increment_factor in [1, -1]:
			var i = increment_factor
			while is_same_flower(cell_just_placed + direction * i, flower):
				lineup_cells.append(cell_just_placed + direction * i)
				i += increment_factor
		
		# check if the combination is long enough
		if len(lineup_cells) >= 3:
			all_lineup_cells += lineup_cells
		
	if len(all_lineup_cells) > 1:
		make_coins(all_lineup_cells)
		
		game.emit_signal("increase_coins", player_number, len(all_lineup_cells))

func make_coins(places):
	var coins = [] 
	var coin: Sprite 
	
	for place in places:
		coin = place_sprite(place.x, place.y, coin_texture, false)
		map[place.x][place.y] = Cell.Grass
		coins.append(coin)
	
	yield(get_tree().create_timer(1), "timeout")
	
	for coin_ in coins:
		coin_.queue_free()

	
