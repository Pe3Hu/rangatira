extends Line2D


onready var tilemap = get_parent().get_node("TileMap")
var draw_line = []
var n = 6
var direction_differences = [
    [[ 0, -1], [+1,  0], [ 0, +1],
     [-1, +1], [-1,  0], [-1, -1]],
    [[+1, -1], [+1,  0], [+1, +1],
     [ 0, +1], [-1,  0], [ 0, -1]]
]

var _half_cell_size
var a 
var b
const DRAW_COLOR = Color.white
const BASE_LINE_WIDTH = 3.0

# Declare member variables here. Examples:
func _ready():
	a = tilemap.cell_size.x / 2
	b = tilemap.cell_size.x / 6 
	var point_start = Vector2(3,1)
	tilemap.set_cell(point_start.x, point_start.y, 1)
	
	for _i in n-0:
		var point_new = _offset_neighbor(point_start,_i)
		tilemap.set_cell(point_new.x, point_new.y, 0)
		draw_line.append(point_new)
		print(point_new)

func _draw():
	for index in range(0, len(draw_line)-1):
		var current_point = tilemap.map_to_world(Vector2(draw_line[index].x, draw_line[index].y)) + Vector2(a,b)
		var next_point = tilemap.map_to_world(Vector2(draw_line[index+1].x, draw_line[index+1].y)) + Vector2(a,b)
		
		draw_line(current_point, next_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)

func _offset_neighbor(hex, direction):
	var parity = fmod(hex.y, 2)
	var diff = direction_differences[parity][direction]
	return Vector2(hex.x + diff[0], hex.y + diff[1])
