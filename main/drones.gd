extends Node


onready var drone_original = load("res://drone/drone.tscn")
var starts = [Vector2(1,1), Vector2(3,1), Vector2(5,1), Vector2(7,1), Vector2(9,1), Vector2(11,1),Vector2(1,3), Vector2(3,3), Vector2(5,3), Vector2(7,3), Vector2(9,3), Vector2(11,3)]
var all_ready = false
var primary_index = {}

func _ready():
	primary_index.drone = 0
	
	for start in starts:
		var drone = drone_original.instance()
		drone._index = primary_index.drone 
		add_child(drone)
		drone.set_start(start)
		primary_index.drone += 1

