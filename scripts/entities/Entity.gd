class_name Entity
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
var max_allowed_actions = 0;
var MAX_MOVES_PER_TURN
var ENTITY_NAME

func _init(entity_given_name, entity_max_moves):
	ENTITY_NAME = entity_given_name
	MAX_MOVES_PER_TURN = entity_max_moves
	max_allowed_actions = MAX_MOVES_PER_TURN
	
func new_turn():
	max_allowed_actions = MAX_MOVES_PER_TURN

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
