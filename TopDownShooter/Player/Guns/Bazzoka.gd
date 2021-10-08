extends Weapon 

func _ready():
	bullet_scene = preload("res://Player/Ammo/Bomb.tscn")
	firerate = 2 

func shoot_():
	var bomb = bullet_scene.instance()
	
	shoot_bullet(bomb)

