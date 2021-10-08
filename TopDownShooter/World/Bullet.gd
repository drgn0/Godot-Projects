extends Area2D

class_name Bullet 

export (int) var damage 
export (int) var knockback 
export (int) var speed

# var color: Color 
export var velocity_dir: Vector2

# func draw_normal_bullet():
func _draw():
	# draws body
	var size = 2
	var color = Color(1, 1, 1)
	draw_circle(Vector2(-size, 0), size, color)
	draw_rect(Rect2(Vector2(-size, -size), Vector2(size, size) * 2), color)
	draw_circle(Vector2(size, 0), size, color)
	# draw_circle(Vector2(), 4, Color(1, 1, 1)) 



func _physics_process(delta):
	# print(velocity)
	position += (velocity_dir * speed) * delta


func _on_Bullet_body_entered(body):
	if body.get_collision_layer_bit(2):  # Player
		return 
	
	if body.get_collision_layer_bit(1):  # Enemy
		# body.get_damage(damage) 
		body.emit_signal("get_damage", damage)
		# body.knockback(knockback, global_position)
		## body.emit_signal("get_knockback", knockback, global_position) 
		
	hit()
	queue_free()

func hit():
	# to be overridden
	pass

func _on_despawn_timeout():
	hit() 
	queue_free()
