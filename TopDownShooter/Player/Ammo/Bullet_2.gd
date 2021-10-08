extends Bullet

func _ready():
	# draw_normal_bullet()
	damage = 6
	knockback = 15
	$despawn.start(0.5)
	speed = 200
	velocity_dir = transform.x
