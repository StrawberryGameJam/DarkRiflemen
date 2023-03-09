extends Entity

# Passing name and maximum actions per turn
func _init().("RIFLEMAN 1", 2):
	pass
	
func _input(event): # Input to get events
	if max_allowed_actions > 0: # Checks if moves are available
		if _state == STATES.IDLE: # Checks if if is doing nothing, to stop players from repeating clicks
			if selected and event.is_action_pressed('click'): # Checks if it was selected and is a movement click
				target_position = get_global_mouse_position(); # Gets target
				var target_tile = _tile(target_position); # Gets tile of the target
				var target_tile_value = get_parent().get_node('TileMap').get_cell(target_tile.x, target_tile.y); # Gets movement value (1,2,3) of the target from parent
				print(target_tile,":", target_tile_value) # Prints current tile and value
				if target_tile_value <= max_allowed_actions: # Checks if movement allows
					print("am here")
					max_allowed_actions -= target_tile_value # discounts movement
					_change_state(STATES.FOLLOW)
				else:
					print("or here")
					print("Ilegal move"); 
				get_parent().get_node('TileMap').clear_movement_area() # Clears movement area
				selected = false # Deselects
			# If the player clicks to select
			elif event.is_action_pressed('click'): 
				if(_tile(get_global_mouse_position()) == tile_position): # If it was on his tile, it's selecting him
					selected = true;
					get_parent().get_node('TileMap').draw_movement_area(position) # Draws from position

