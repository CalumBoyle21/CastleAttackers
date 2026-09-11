class_name GatherState
extends AgentState

var gather_timer: float = 0.0
var is_gathering: bool = false

func enter() -> void:
	is_gathering = false
	agent.target_resource_node = WorldRegistry.get_nearest_resource_node(agent.global_position)
	if agent.target_resource_node == null:
		state_machine.change_state("Idle")
		return
	agent.set_move_target(agent.target_resource_node.global_position)

func physics_update(delta: float) -> void:
	if agent.target_resource_node == null or not is_instance_valid(agent.target_resource_node):
		state_machine.change_state("Wander")
		return

	if not is_gathering:
		agent.move_along_path(delta)
		if agent.has_reached_target():
			is_gathering = true
			gather_timer = VillagerAgent.GATHER_DURATION
	else:
		gather_timer -= delta
		if gather_timer <= 0.0:
			agent.carrying_resource = agent.target_resource_node.harvest()
			agent.target_resource_node = null
			state_machine.change_state("Deliver")
