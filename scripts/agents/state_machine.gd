class_name AgentStateMachine
extends Node

## FSM for vilAgent

@export var initial_state: String = "Idle"

var agent: VillagerAgent
var states: Dictionary = {}
var current_state: AgentState

func _ready() -> void:
	agent = get_parent()
	for child in get_children():
		if child is AgentState:
			states[child.name] = child
			child.agent = agent
			child.state_machine = self
	if states.has(initial_state):
		change_state(initial_state)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
	agent.physics_step(delta)

func change_state(state_name: String) -> void:
	if not states.has(state_name):
		push_warning("AgentStateMachine: unknown state '%s'" % state_name)
		return
	if current_state:
		current_state.exit()
	current_state = states[state_name]
	current_state.enter()
