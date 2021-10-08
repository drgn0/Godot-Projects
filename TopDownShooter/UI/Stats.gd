extends CanvasLayer

const GREEN = Color(0, 1, 0) 
const YELLOW = Color(1, 1, 0)
const RED = Color(1, 0, 0) 

onready var health_bar = $MarginContainer/HBoxContainer/HealthBar
export var initial_offset = Vector2(-20, 20) 
onready var parent = get_parent()
onready var camera = get_tree().get_root().get_node("World").get_node("Player").get_node("Camera2D") 

func _process(delta):
	offset = parent.global_position - camera.get_camera_position() + OS.get_window_size() / 2 + initial_offset
	
func update_health_bar(new_health):
	health_bar.value = new_health
	
	if new_health > 70:
		health_bar.tint_progress = GREEN
	elif new_health > 30:
		health_bar.tint_progress = YELLOW
	else:
		health_bar.tint_progress = RED
	
	health_bar.visible = true
	health_bar.get_node("HealthBarTimer").start(1) 


func _on_HealthBarTimer_timeout():
	health_bar.visible = false 
