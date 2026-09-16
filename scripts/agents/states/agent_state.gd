class_name AgentState
extends Node

## Base class for all villager states.

var agent: VillagerAgent
var state_machine: AgentStateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
