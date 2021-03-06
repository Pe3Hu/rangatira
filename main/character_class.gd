extends Node2D


class drone:
	enum States { IDLE, FOLLOW }

	const MASS = 10.0
	const ARRIVE_DISTANCE = 1

	export(float) var speed = 200.0
	var _state = States.IDLE

	var _path = []
	var _cells = []
	var _target_point_world = Vector2()
	var _target_position = Vector2()
	var _previous_cells = []
	var _velocity = Vector2()
	var pos = Position2D.new()
	var tilemap = null

	func _init(_tilemap):
		tilemap = _tilemap
		pos.position = tilemap.map_to_world(Vector2(0, 0))
		_change_state(States.IDLE)
		var texture = ImageTexture.new()
		var image = Image.new()
		image.load("res://assets/1_sector.png")
		texture.create_from_image(image)
		var texture2 = ImageTexture.new()
		var image2 = Image.new()
		image2.load("res://assets/2_sector.png")
		texture2.create_from_image(image2)
		
		for _i in 6:
			var s = Sprite.new()
			var a = 24/2
			var angle_rotation = PI/6 + (4+_i)*PI/3
			var ange_shift = PI/3*0
			var shift = Vector2(sin(ange_shift)*a,cos(ange_shift)*a)
			if _i == 0:
				s.texture = texture
			else:
				s.texture = texture2
			s.offset = pos.position + shift
			s.z_index = 3
			s.scale = Vector2(0.5,0.5)
			s.rotation = angle_rotation
			pos.add_child(s)
			
		_target_position = tilemap.map_to_world(Vector2(1, 1))
		
		_change_state(States.FOLLOW)

	func _process(_delta):
		#print(_state,pos.position)
		if _state != States.FOLLOW:
			return
		
		var _arrived_to_next_point = _move_to(_target_point_world,_delta)
		print(_arrived_to_next_point)
		
		if _arrived_to_next_point:
			if len(_path) > 1:
				tilemap.set_cell(_cells[1].x, _cells[1].y, 2)
				if len(_previous_cells) > 0:
					tilemap.set_cell(_previous_cells[0].x, _previous_cells[0].y, 0)
					_previous_cells.remove(0)
			if len(_path) == 1:
				pos.position = _path[0]
				tilemap.set_cell(_previous_cells[0].x, _previous_cells[0].y, 0)
				_path.remove(0)
				_cells.remove(0)
				_change_state(States.IDLE)
				return
			
			_previous_cells.append(_cells[0])
			tilemap.set_cell(_cells[0].x, _cells[0].y, 2)
			_path.remove(0)
			_cells.remove(0)
			_target_point_world = _path[0]

	func _unhandled_input(event):
		
		if event.is_action_pressed("click") && _state == States.IDLE:
			while len(_previous_cells) > 0:
				tilemap.set_cell(_previous_cells[0].x, _previous_cells[0].y, 0)
				_previous_cells.remove(0)
			
			var global_mouse_pos = pos.get_global_mouse_position()
			
			if Input.is_key_pressed(KEY_SHIFT):
				pos.global_position = global_mouse_pos
			else:
				_target_position = global_mouse_pos
				
			_change_state(States.FOLLOW)

	func _move_to(world_position,_delta):
		var desired_velocity = (world_position - pos.position).normalized() * speed
		var steering = desired_velocity - _velocity
		
		_velocity += steering / MASS
		pos.position += _velocity * _delta
		pos.rotation = _velocity.angle() 
		return pos.position.distance_to(world_position) < ARRIVE_DISTANCE

	func _change_state(new_state):
		if new_state == States.FOLLOW:
			var result = tilemap.get_astar_path(pos.position, _target_position)
			_path = result["path"]
			_cells = result["cells"]
			
			if not _path or len(_path) == 1:
				_change_state(States.IDLE)
				return
			
			_target_point_world = _path[1]
		
		_state = new_state
