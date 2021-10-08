extends Node2D

const firing_speed = 0.5  # sec 
const bullet_scene = preload("res://World/Bullet.tscn")
const bullet_speed = 300


onready var can_shoot = true 

func shoot():
	if can_shoot:
		var bullet_instance = bullet_scene.instance() 
		bullet_instance.position = $GunPoint.global_position
		bullet_instance.transform.x = transform.x
		bullet_instance.set_velocity(transform.x * bullet_speed)
		
		# bullet_instance.set_collision_mask_bit(1, 2)
		
		get_tree().get_root().get_node("World").add_child(bullet_instance) 
		
		can_shoot = false
		$Timer.start(firing_speed)
	


func _on_Timer_timeout():
	can_shoot = true
