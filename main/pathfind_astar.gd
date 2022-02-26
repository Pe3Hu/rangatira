extends TileMap

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color.white
const n = 6

export(Vector2) var map_size = Vector2.ONE * 16

var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position

var _point_path = []
var direction_differences = [
	[[ 1, -1], [+1,  0], [ 0, +1],
     [-1,  0], [-1, -1], [ 0, -1]],
    [[+1,  0], [+1, +1], [ 0, +1],
     [-1, +1], [-1,  0], [ 0, -1]]
]

onready var astar_node = AStar.new()
onready var obstacles = get_used_cells_by_id(0)
onready var hex_shift = Vector2(cell_size.x / 2, (cell_size.y /2+ cell_size.x / sqrt(3))/ 2)
var reserved_tiles = {}


func _ready():
	for y in range(map_size.y):
		for x in range(map_size.x):
			set_cell(x, y, 0)
	
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)
	
	_point_path = []

func _draw():
	if not _point_path:
		return
	
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]

	set_cell(point_start.x, point_start.y, 0)
	set_cell(point_end.x, point_end.y, 1)

	var last_point = map_to_world(Vector2(point_start.x, point_start.y)) + hex_shift
	
	for index in range(1, len(_point_path)):
		var current_point = map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + hex_shift
		
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
		last_point = current_point

func astar_add_walkable_cells(obstacle_list = []):
	var points_array = []
	
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			
			if point in obstacle_list:
				continue
			
			points_array.append(point)
			var point_index = calculate_point_index(point)
			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	
	return points_array

func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		
		for _i in n:
			var point_relative = _offset_neighbor(point, _i)
			var point_relative_index = calculate_point_index(point_relative)
			
			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			
			astar_node.connect_points(point_index, point_relative_index, false)

func clear_previous_path_drawing():
	if not _point_path:
		return
	
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]
	
	set_cell(point_start.x, point_start.y, 0)
	set_cell(point_end.x, point_end.y, 0)

func get_astar_path(world_start, world_end):
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	
	_recalculate_path()
	
	var path_world = []
	var path_cells = []
	
	for point in _point_path:
		var point_world = map_to_world(Vector2(point.x, point.y)) + hex_shift
		path_cells.append(Vector2(point.x, point.y))
		path_world.append(point_world)
	var result = {
		"path": path_world,
		"cells": path_cells
	}
	return result

func _recalculate_path():
	clear_previous_path_drawing()
	
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	
	update()

func _set_path_start_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, -1)
	path_start_position = value
	
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()

func _set_path_end_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, -1)
	path_end_position = value
	
	if path_start_position != value:
		_recalculate_path()

func calculate_point_index(point):
	return point.x + map_size.x * point.y

func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y

func _offset_neighbor(hex, direction):
	var parity = fmod(hex.x, 2)
	var diff = direction_differences[parity][direction]
	return Vector2(hex.x + diff[0], hex.y + diff[1])
