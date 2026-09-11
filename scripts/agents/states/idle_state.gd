class_name IdleState
extends AgentState

var wait_time: float = 0.0

func enter() -> void:
	wait_time = randf_range(1.0, 3.0)
	agent.velocity.x = 0
	agent.velocity.z = 0

func physics_update(delta: float) -> void:
	wait_time -= delta
	if wait_time <= 0.0:
		state_machine.change_state("Wander")
