extends Position2D

export(float) var SPEED = 200.0

enum STATES { IDLE, FOLLOW }
var _state = null

var path = []
var target_point_world = Vector2()
var target_position = Vector2()

var velocity = Vector2()

var tile_position = Vector2();
var selected = false;
var actions_taken = 0;

func _ready():
	tile_position = _tile(position)
	_change_state(STATES.IDLE)

func _tile(point):
	return get_parent().get_node('TileMap').world_to_map(point)

func _change_state(new_state):
	if new_state == STATES.FOLLOW:
		path = get_parent().get_node('TileMap').find_path(position, target_position)
		if not path or len(path) == 1:
			get_parent().get_node('TileMap').clear_previous_path_drawing()
			_change_state(STATES.IDLE)
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		target_point_world = path[1]
	_state = new_state


func _process(_delta):
	if not _state == STATES.FOLLOW:
		return
	var arrived_to_next_point = _move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		tile_position = _tile(position);
		if len(path) == 0:
			get_parent().get_node('TileMap').clear_previous_path_drawing()
			_change_state(STATES.IDLE)
			return
		target_point_world = path[0]


func _move_to(world_position):
	var MASS = 10.0
	var ARRIVE_DISTANCE = 10.0

	var desired_velocity = (world_position - position).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	position += velocity * get_process_delta_time()
	rotation = velocity.angle()
	return position.distance_to(world_position) < ARRIVE_DISTANCE


func _input(event):
	if _state == STATES.IDLE:
		if selected and event.is_action_pressed('click'):
			target_position = get_global_mouse_position();
			var target_tile = _tile(target_position);
			var target_tile_value = get_parent().get_node('TileMap').get_cell(target_tile.x, target_tile.y);
			print(target_tile,":", target_tile_value)
			if target_tile_value in [1,2]:
				if target_tile_value == 1:
					actions_taken += 1
				else:
					actions_taken += 2
				_change_state(STATES.FOLLOW)
			get_parent().get_node('TileMap').clear_movement_area()
			selected = false
		elif event.is_action_pressed('click'):
			if(_tile(get_global_mouse_position()) == tile_position):
				selected = true;
				get_parent().get_node('TileMap').draw_movement_area(position)

