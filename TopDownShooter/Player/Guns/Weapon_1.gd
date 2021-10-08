extends Weapon 

func _ready(): 
	bullet_scene = preload("res://Player/Ammo/Bullet_1.tscn")
	firerate = 0.5  # sec

func shoot_():
	var bullet = bullet_scene.instance() 
	
	shoot_bullet(bullet)
