extends Node2D

const EnemyTriangleScene = preload("res://Enemy/EnemyTriangle.tscn")

export var max_enemies = 5 
export var spawn_time = 2 

signal get_money(money)
signal change_weapon(weapon_number) 

onready var player = $Player 


func _ready():
	randomize()


func find_position_to_spawn_enemy():
	var spawn_points = $SpawnPoints.get_children()
	spawn_points.shuffle()
	for spawn_point in spawn_points:
		if not spawn_point.get_overlapping_bodies():
			return spawn_point.position 
	
	
func _on_SpawnTimer_timeout():
	if $Enemies.get_child_count() < max_enemies:
		# spawn enemy 
		var enemyTriangle = EnemyTriangleScene.instance() 
		var enemy_position = find_position_to_spawn_enemy()
		if enemy_position == null:
			return 
			
		enemyTriangle.position = enemy_position

		enemyTriangle.rotation = rand_range(-PI, PI) 
		
		$Enemies.add_child(enemyTriangle) 


func _on_World_get_money(money_gained):
	var money_label = $Stats/Money
	money_label.text = str(int(money_label.text) + money_gained)
	
	max_enemies = 5 + int(money_label.text) / 50 



func _on_World_change_weapon(weapon_number):
	$Stats/Weapon.text = str(weapon_number)
