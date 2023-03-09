# PATHFINDING Script
#
# Description: heavily modified code based on GDQuest's A* pathfinding script.
# This script and the tilemap are responsible for the movement in tiles, positioning in tiles
# pathfinding, drawing in the map and calculating everything related to movement.
#
# Variable clarification: if it is in FULL_CAPS it is a constant. _variables or _methods are private
# (altought they can still be acessed)

extends TileMap

# Creates pathfinding node.
onready var astar_node = AStar.new()
# The tilemap doesn't have defined boundaries, so we create them here
const MAP_WIDTH = 16
const MAP_HEIGHT = 16
export(Vector2) var map_size = Vector2(MAP_WIDTH, MAP_HEIGHT)

# path_start and end variables are set by these functions. The array of points is empty
var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position
var _point_path = []

# Definind some constants for drawing.
const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color('#fff')
onready var _HALF_CELL_SIZE = cell_size / 2

# Creates the obstacles by getting the cells with id 0 (obstacle)
onready var obstacles = get_used_cells_by_id(0)

# Function runs when node and children enter active state in scene. 
# That is, it runs once when everything is ready.
func _ready():
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)


# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles
func astar_add_walkable_cells(found_obstacles = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if point in found_obstacles:
				continue
			points_array.append(point)
			# Reminder: A* in godot uses int indices for points.
			var point_index = calculate_point_index(point)
			# A* returns vectors in 3d. So remember to get only x and y.
			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array

# Once you added all points to the AStar node, you've got to connect them
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...
func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the ones besides them.
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)
			# If outside map or if already added.
			if is_outside_map_bounds(point_relative):
				continue
			# If
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A
			# If you set this value to false, it becomes a one-way path
			# As we loop through all points we can set it to false
			astar_node.connect_points(point_index, point_relative_index, false)


# This is a variation of the method above
# It connects cells horizontally, vertically AND diagonally
func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)
				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)


func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func calculate_point_index(point):
	return point.x + map_size.x * point.y


func find_path(world_start, world_end):
	self.path_start_position = world_to_map(world_start)
	self.path_end_position = world_to_map(world_end)
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = map_to_world(Vector2(point.x, point.y)) + _HALF_CELL_SIZE
		path_world.append(point_world)
	return path_world


func _recalculate_path():
	clear_previous_path_drawing()
	var start_point_index = calculate_point_index(path_start_position)
	var end_point_index = calculate_point_index(path_end_position)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	# Redraw the lines and circles from the start to the end point
	update()


func clear_previous_path_drawing():
	if not _point_path:
		print("Not cleaning")
		return
	print("Cleaning")
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]
	set_cell(point_start.x, point_start.y, -1)
	set_cell(point_end.x, point_end.y, -1)

func clear_movement_area():
	for point in points_draw_area:
		var tile_position = astar_node.get_point_position(point);
		set_cell(tile_position.x, tile_position.y, -1)
	return

func rec_movement_area(smaller_radius, bigger_radius, point, points):
	if bigger_radius > 0 or smaller_radius > 0:
		var tile_position = astar_node.get_point_position(point);
		if smaller_radius > 0:
			set_cell(tile_position.x, tile_position.y, 1)
		elif get_cell(tile_position.x, tile_position.y) != 1:
			set_cell(tile_position.x, tile_position.y, 2)
		points.append(point);
		for neighbor in astar_node.get_point_connections(point):
			rec_movement_area(smaller_radius-1, bigger_radius-1, neighbor, points);
	return 	

var points_draw_area = []
func draw_movement_area(position):
	points_draw_area = []
	var tile_position = world_to_map(position);
	var point_index = calculate_point_index(tile_position);
	rec_movement_area(3,5,point_index,points_draw_area)
	

func _draw():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]
	set_cell(point_start.x, point_start.y, 1)
	set_cell(point_end.x, point_end.y, 2)

	var last_point = map_to_world(Vector2(point_start.x, point_start.y)) + _HALF_CELL_SIZE
	for index in range(1, len(_point_path)):
		var current_point = map_to_world(Vector2(_point_path[index].x, _point_path[index].y)) + _HALF_CELL_SIZE
		draw_line(last_point, current_point, DRAW_COLOR, BASE_LINE_WIDTH, true)
		draw_circle(current_point, BASE_LINE_WIDTH * 2.0, DRAW_COLOR)
		last_point = current_point

# Setters for the start and end path values.
func _set_path_start_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, 1)
	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value):
	if value in obstacles:
		return
	if is_outside_map_bounds(value):
		return

	set_cell(path_start_position.x, path_start_position.y, -1)
	set_cell(value.x, value.y, 2)
	path_end_position = value
	if path_start_position != value:
		_recalculate_path()
