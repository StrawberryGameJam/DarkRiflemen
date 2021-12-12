extends Entity

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

