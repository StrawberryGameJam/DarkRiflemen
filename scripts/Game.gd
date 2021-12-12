extends Node

var player = 0
func _input(event):
	if player == 0 and event is InputEventKey:
		if (event as InputEventKey).scancode == KEY_ESCAPE and not event.echo:
			print("Player clicked escape")
			player = 1;
			get_node('Zombie').zombie_actions();
			player = 0;
