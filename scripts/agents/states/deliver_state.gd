class_name DeliverState
extends AgentState

var deliver_timer: float = 0.0
var is_delivering: bool = false

func enter() -> void:
	is_delivering = false
	agent.target_drop_off = WorldRegistry.get_nearest_drop_off(agent.global_position)
	if agent.target_drop_off == null:
		state_machine.change_state("Idle")
		return
	agent.set_move_target(agent.target_drop_off.global_position)

func physics_update(delta: float) -> void:
	if agent.target_drop_off == null or not is_instance_valid(agent.target_drop_off):
		state_machine.change_state("Wander")
		return

	if not is_delivering:
		agent.move_along_path(delta)
		if agent.has_reached_target():
			is_delivering = true
			deliver_timer = VillagerAgent.DELIVER_DURATION
	else:
		deliver_timer -= delta
		if deliver_timer <= 0.0:
			agent.target_drop_off.deposit(agent.carrying_resource)
			agent.carrying_resource = ""
			agent.target_drop_off = null
			state_machine.change_state("Gather")
