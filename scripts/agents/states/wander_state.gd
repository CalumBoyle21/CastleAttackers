class_name WanderState
extends AgentState

const WANDER_RADIUS: float = 8.0

func enter() -> void:
	var offset := Vector3(
		randf_range(-WANDER_RADIUS, WANDER_RADIUS),
		0,
		randf_range(-WANDER_RADIUS, WANDER_RADIUS)
	)
	agent.set_move_target(agent.home_position + offset)

func physics_update(delta: float) -> void:
	agent.move_along_path(delta)
	if agent.has_reached_target():
		if WorldRegistry.has_available_resource():
			state_machine.change_state("Gather")
		else:
			state_machine.change_state("Idle")
