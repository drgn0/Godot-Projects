extends KinematicBody2D

signal get_damage(damage)
signal get_knockback(intensity, impact_position)

#  Stats------------------------------------------------------------
export var max_health = 100
onready var health = max_health
export var immune_time = 0.6
onready var money = 0

onready var selected_weapon = 1
export var no_of_weapons = 3

#  Kinematics-------------------------------------------------------
const max_speed = 240

const acceleration = 0.04
const friction = 0.02

onready var velocity = Vector2() 
onready var immune = false



func take_input():
	var input_vector = Vector2()
	if Input.is_action_pressed("right"):
		input_vector.x += 1
	if Input.is_action_pressed("left"):
		input_vector.x -= 1
	if Input.is_action_pressed("down"):
		input_vector.y += 1
	if Input.is_action_pressed("up"):
		input_vector.y -= 1
	
	return input_vector.normalized()
	

func move():
	var input_vector = take_input() 
	
	if input_vector.x or input_vector.y:
		velocity = lerp(velocity, input_vector * max_speed, acceleration)
	else:
		velocity = lerp(velocity, Vector2(), friction)
	
	velocity = move_and_slide(velocity)
	

func _physics_process(delta):
	move() 
	change_weapon() 
	try_to_shoot() 


func change_weapon():
	if Input.is_action_just_pressed("next_weapon"):
		if selected_weapon < no_of_weapons:
			$Weapons.get_child(selected_weapon - 1).visible = false
			selected_weapon += 1 
			get_parent().emit_signal("change_weapon", selected_weapon)
			$Weapons.get_child(selected_weapon - 1).visible = true
	elif Input.is_action_just_pressed("prev_weapon"):
		if selected_weapon > 1:
			$Weapons.get_child(selected_weapon - 1).visible = false
			selected_weapon -= 1
			get_parent().emit_signal("change_weapon", selected_weapon)
			$Weapons.get_child(selected_weapon - 1).visible = true
	
func try_to_shoot():
	var gun = $Weapons.get_child(selected_weapon - 1) 
	
	gun.look_at(get_global_mouse_position())
	if not Input.is_action_pressed("shoot"):
		return 
	
	gun.shoot() 


func get_damage(damage):
	if not immune:
		health -= damage
		if health <= 0:
			die()
			
		update_health()
		be_immune()

func update_health():
	$Stats.update_health_bar(health) 
	
	var health_label = get_parent().get_node("Stats").get_node("Health") 
	health_label.text = str(health) 

func be_immune():
	immune = true 
	# $ImmuneTimer.start(immune_time)
	yield(get_tree().create_timer(immune_time), "timeout")
	immune = false

func get_knockback(intensity, impact_pos):
	if not immune:
		var impact_vector = -to_local(impact_pos).normalized()
		
		velocity += impact_vector * intensity 
		

func die():
	print("You Died !!  mere mortal.") 
	get_tree().quit()
	# queue_free() 
