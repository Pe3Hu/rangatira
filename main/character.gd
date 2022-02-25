extends Node2D


onready var drone = load("res://drone/drone.tscn")

func _ready():
	var drone = drone.instance()
	add_child(drone)

