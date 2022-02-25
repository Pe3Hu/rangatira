extends Node


onready var drone_original = load("res://drone/drone.tscn")
var starts = [Vector2(1,1), Vector2(7,1), Vector2(13,1)]
var all_ready = false

func _ready():
	for start in starts:
		var drone = drone_original.instance()
		add_child(drone)
		drone.set_start(start)

func _process(delta):
	for drone in get_children():
		all_ready = all_ready && drone.check_start_position()
	if all_ready:
		print("all ready")
