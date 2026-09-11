class_name AgentState
extends Node

## Base class for all villager states. Subclass this and add the node
## as a child of a StateMachine node to register a new state by name.

var agent: VillagerAgent
var state_machine: AgentStateMachine

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
