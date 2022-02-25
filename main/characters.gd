extends Node


onready var tilemap = get_parent().get_node("TileMap")
var characters = []

func _ready():
	var character = Character.drone.new(tilemap)
	characters.append(character)
	
func _process(_delta):
	for character in characters:
		character._process(_delta)

func _unhandled_input(event):
	for character in characters:
		character._unhandled_input(event)

