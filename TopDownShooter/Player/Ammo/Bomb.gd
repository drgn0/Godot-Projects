extends Bullet 

export var color_of_bomb = Color(1, 1, 0)
onready var blast_damage = 40 

func _ready():
	damage = 10
	speed = 200
	
	$despawn.start(8)
	velocity_dir = transform.x

func _draw():
	# hoping that _draw of parent class Bullet will not be called.  :v
	var radius = 4 
	draw_circle(Vector2(), radius, color_of_bomb)
func hit():
	for body in $Blast.get_overlapping_bodies():
		if body.get_collision_layer_bit(1):
			body.emit_signal("get_damage", blast_damage)
