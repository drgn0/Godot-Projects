extends Bullet 

func _ready():
	# draw_normal_bullet()
	damage = 10
	knockback = 20
	$despawn.start(6)
	speed = 400
	velocity_dir = transform.x
