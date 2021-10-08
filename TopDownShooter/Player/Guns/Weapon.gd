extends Node2D

class_name Weapon 

# export var bullet_scene = preload("res://Player/Ammo/Bullet_1.tscn")

export (int) var firerate 
export (int) var bullet_speed 
export (int) var bullet_despawn_time 
export (int) var bullet_damage 

var bullet_scene

onready var Bullets = get_tree().get_root().get_node("World").get_node("Bullets") 
onready var can_shoot = true 


func shoot_():
	# to be overridden 
	pass

func shoot_bullet(bullet = null, angular_offset = 0):
	# if bullet == null:
	# 	bullet = bullet_scene.instance() 
	
	# bullet.get_node("despawn").wait_time = bullet_despawn_time
	# bullet.draw_normal_bullet()
	bullet.position = $GunPoint.global_position
	bullet.transform.x = transform.x.rotated(angular_offset)
	# bullet.velocity = transform.x.rotated(angular_offset) * bullet_speed
	# bullet.damage = bullet_damage 
	
	Bullets.add_child(bullet) 
	
func shoot():
	if can_shoot:
		shoot_()
		can_shoot = false 
		$CanShootTimer.start(firerate) 
	


func _on_CanShootTimer_timeout():
	can_shoot = true
