extends Node

enum {PLAYER_TURN, ENEMY_TURN}

var current_turn = PLAYER_TURN
func _input(event):
	if current_turn == PLAYER_TURN and event is InputEventKey:
		if (event as InputEventKey).scancode == KEY_ESCAPE and not event.echo:
			print("Player clicked escape")
			
			current_turn = ENEMY_TURN;
			get_node('Zombie').zombie_actions();
			current_turn = PLAYER_TURN;
