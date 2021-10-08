extends Node2D

# export var radius = 50 
export var coin_value = 10
export var attraction_speed = 120

export var despawn_time = 10  #  + rand_range(0, delta_despawn_time)
export var delta_despawn_time = 4
# export var initial_speed = 100

const friction = 100


var other_velocity: Vector2
# onready var velocity_towards_player = Vector2()
onready var player

func _ready():
	var initial_speed = 100 * rand_range(0.1, 1) 
	other_velocity = Vector2(initial_speed, 0).rotated(rand_range(-PI, PI))
	
	$DespawnTimer.start(despawn_time + rand_range(0, delta_despawn_time))

func _on_attract_body_exited(body):
	if body.name == 'Player':
		player = null

func _on_attract_body_entered(body):
	if body.name == 'Player':
		player = body 
	

func _physics_process(delta):
	var velocity_towards_player = Vector2() 
	if player:
		velocity_towards_player = (player.position - position).normalized() * attraction_speed
	
	other_velocity = other_velocity.move_toward(Vector2(), friction * delta)
	
	position += (velocity_towards_player + other_velocity) * delta
	

func _on_collide_body_entered(body):
	# print(body)
	if body.name == 'Player':
		body.get_parent().emit_signal("get_money", coin_value)
		queue_free()
	else:
		other_velocity = Vector2() 


func _on_DespawnTimer_timeout():
	queue_free()
