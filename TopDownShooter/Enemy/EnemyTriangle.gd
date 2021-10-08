extends Enemy


const DIRECTIONS_TO_CONSIDER = 8
const LENGTH_OF_RAYS = 80

const separation_factor = 0.012
const inner_radius = 100
const outer_radius = 300


var can_move = true 
onready var world = get_tree().get_root().get_node("World")
onready var player = world.get_node("Player") 


var velocity = Vector2()


# State--------------------------------------------
var health: int

onready var alive = true  # :v


func _draw():
	draw_body()

func draw_body():
	# constants
	var triangle_size = 8
	var triangle_height = 4
	var triangle_width = 2
	
	var color_of_triangle = Color(1, 0.3, 0.4)  # Red
	
	var points = PoolVector2Array([]) 
	
	points.append(Vector2( triangle_height / 2, 0) * triangle_size)
	points.append(Vector2(-triangle_height / 2, triangle_width)  * triangle_size)
	points.append(Vector2(-triangle_height / 2, -triangle_width) * triangle_size) 
	
	
	draw_colored_polygon(points, color_of_triangle)

func _ready():
	initialise_rays()
	$Stats.initial_offset = Vector2(-20, 20) 
	
	maxSpeed = 180
	linear_acceleration = 100
	angular_acceleration = 4
	
	max_health = 100
	
	
	health = max_health
	

func initialise_rays():
	for i in range(DIRECTIONS_TO_CONSIDER):
		var ray = RayCast2D.new()
		ray.enabled = true
		ray.position = Vector2(16, 0)  # HOPING that rotation is zero.  :v  
		
		ray.add_exception(self)
		# ray.add_exception(player)
		ray.set_collision_mask_bit(0, 1)
		ray.set_collision_mask_bit(1, 2)
		# print(ray.get_collision_mask_bit(2)) 
		ray.cast_to = Vector2(1, 0).rotated(i * 2 * PI / DIRECTIONS_TO_CONSIDER)  * LENGTH_OF_RAYS
		
		$Rays.add_child(ray)

func find_target_length_factor(target):
	var target_length = target.length()
	var target_length_factor 
	
	if target_length > outer_radius:
		target_length_factor = target_length * 1.5
	elif target_length > inner_radius:
		target_length_factor = target_length 
	else:
		target_length_factor = target_length * 0.5
	
	
	return target_length_factor

func find_repulsion(target_length_factor):
	var total_repulsion = Vector2() 
	
	for ray in $Rays.get_children():
		if ray.is_colliding():
			var collision_vector = ray.get_collision_point() - position 
			var collision_length = 1 - collision_vector.length() / LENGTH_OF_RAYS
			var repulsion = separation_factor * target_length_factor * collision_length 
			
			# print(repulsion)
			total_repulsion += -collision_vector * repulsion
		
	return total_repulsion

func find_target_pos():
	# returns target position PLUS THE SEPARATION FACTOR
	var target = to_local(player.global_position)
	# var target = get_local_mouse_position()
	var target_length_factor = find_target_length_factor(target)
	
	return target + find_repulsion(target_length_factor)
	
func update_velocity(target, delta):
	var angle = target.angle()
	if angle < -PI:
		angle += 2 * PI 
	if angle > PI:
		angle -= 2 * PI 
	
	var intention_to_move = cos( angle / 2 )
	

	var speed =  min(inner_radius, target.length()) / inner_radius * maxSpeed 
	# print(speed)
	
	# velocity = lerp(velocity, transform.x * intention_to_move * speed, linear_acceleration * delta)
	velocity = velocity.move_toward(transform.x * intention_to_move * speed, linear_acceleration * delta)


func move(delta):
	var target = find_target_pos()
	
	if can_move:
		update_velocity(target, delta)
		rotation += lerp_angle(0, target.angle(), angular_acceleration * delta)
	
	velocity = move_and_slide(velocity)

func _physics_process(delta):
	move(delta) 
	check_collision()


func check_collision():
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == 'Player':
			# collision.collider.get_knockback(50, collision.position)
			collision.collider.emit_signal("get_knockback", 50, collision.position)
			# collision.collider.get_damage(10)
			collision.collider.emit_signal("get_damage", 10)
			

func get_knockback():
	velocity = Vector2()
	return 
	
	
func get_damage(damage):
	# print(health, damage)
	health -= damage
	get_knockback()
	if health <= 0:
		die() 
		
	$Stats.update_health_bar(health) 
	
func how_many_coins_to_generate():
	var random_no = randi() % 10
	if random_no > 7:  # 20% chances
		return 3
	if random_no > 3:  # 40% chances
		return 2
	
	return 1  # 40% chances 
	
func generate_coins():
	var coins = how_many_coins_to_generate()
	# print(coins, ' coins  :D')
	for _i in range(coins):
		var coin = coin_scene.instance() 
		coin.position = position  # global_position ?
		
		world.add_child(coin)
	

func die():
	if not alive:
		return 
	alive = false
	# print("Enemy Killed")
	generate_coins() 
	
	queue_free() 

