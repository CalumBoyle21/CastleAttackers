class_name PausedState
extends AgentState

func enter() -> void:
	agent.velocity.x = 0
	agent.velocity.z = 0

func physics_update(_delta: float) -> void:
	pass
