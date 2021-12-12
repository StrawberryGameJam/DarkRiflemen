extends Entity

func zombie_actions():
	if _state == STATES.IDLE:
		target_position = get_parent().get_node('Rifleman').position;
		_change_state(STATES.FOLLOW)
