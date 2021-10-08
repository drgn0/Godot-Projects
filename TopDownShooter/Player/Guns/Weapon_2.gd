extends Weapon 

onready var spread = 0.4

func _ready():
	bullet_scene = preload("res://Player/Ammo/Bullet_2.tscn")
	firerate = 1.5  # sec

func spread_factor():
	# returns a random number between -spread to spread
	# numbers near to zero are somewhat more common.
	return rand_range(0, spread) - rand_range(0, spread)
	
func shoot_():
	for _i in range(3 + randi() % 7):
		var bullet = bullet_scene.instance() 
		var offset_angle = (PI / 2) * spread_factor()
		
		shoot_bullet(bullet, offset_angle)
