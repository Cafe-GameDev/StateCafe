@tool
extends Node
class_name StateComponent

signal state_changed(domain: StringName, previous: Resource, next: Resource)
signal state_entered(domain: StringName, state: Resource)
signal state_exited(domain: StringName, state: Resource)

@export var initial_behaviors: Array[Dictionary] = []:
	set(value):
		initial_behaviors = value
		_update_active_behaviors_from_initial()

var active_behaviors: Dictionary = {}
var owner_node: Node
var _is_transitioning: bool = false

func _ready():
	if Engine.is_editor_hint():
		return
	owner_node = get_parent()
	_update_active_behaviors_from_initial()
	_enter_initial_states()

func _process(delta: float):
	if Engine.is_editor_hint():
		return
	for domain in active_behaviors.keys():
		var current_behavior = active_behaviors[domain]
		if current_behavior:
			current_behavior.process(owner_node, delta)

func _physics_process(delta: float):
	if Engine.is_editor_hint():
		return
	for domain in active_behaviors.keys():
		var current_behavior = active_behaviors[domain]
		if current_behavior:
			current_behavior.physics_process(owner_node, delta)

func _update_active_behaviors_from_initial():
	active_behaviors.clear()
	for entry in initial_behaviors:
		var domain = entry.get("domain", "")
		var behavior = entry.get("behavior", null)
		if not domain.is_empty() and behavior:
			active_behaviors[domain] = behavior

func _enter_initial_states():
	for domain in active_behaviors.keys():
		var behavior = active_behaviors[domain]
		if behavior:
			_connect_behavior_signals(domain, behavior)
			behavior.enter(owner_node)
			emit_signal("state_entered", domain, behavior)

func transition_to(domain: StringName, next_behavior: Resource):
	if _is_transitioning or next_behavior == null or not active_behaviors.has(domain):
		return

	var current_behavior = active_behaviors[domain]
	if current_behavior == next_behavior:
		return

	_is_transitioning = true

	if current_behavior:
		_disconnect_behavior_signals(domain, current_behavior)
		current_behavior.exit(owner_node)
		emit_signal("state_exited", domain, current_behavior)

	active_behaviors[domain] = next_behavior

	if next_behavior:
		_connect_behavior_signals(domain, next_behavior)
		next_behavior.enter(owner_node)
		emit_signal("state_entered", domain, next_behavior)

	emit_signal("state_changed", domain, current_behavior, next_behavior)

	_is_transitioning = false

func _on_behavior_transition_requested(domain: StringName, next_behavior: Resource):
	transition_to(domain, next_behavior)

func _connect_behavior_signals(domain: StringName, behavior: Resource):
	if behavior.has_signal("transition_requested") and not behavior.is_connected("transition_requested", Callable(self, "_on_behavior_transition_requested")):
		behavior.transition_requested.connect(Callable(self, "_on_behavior_transition_requested").bind(domain), CONNECT_ONE_SHOT)

func _disconnect_behavior_signals(domain: StringName, behavior: Resource):
	if behavior.has_signal("transition_requested") and behavior.is_connected("transition_requested", Callable(self, "_on_behavior_transition_requested")):
		behavior.transition_requested.disconnect(Callable(self, "_on_behavior_transition_requested").bind(domain))

func handle_event(event_name: StringName, payload: Variant = null):
	for domain in active_behaviors.keys():
		var current_behavior = active_behaviors[domain]
		if current_behavior and current_behavior.has_method("handle_event"):
			current_behavior.handle_event(owner_node, event_name, payload)

func is_in_state(domain: StringName, state_class: StringName) -> bool:
	if active_behaviors.has(domain) and active_behaviors[domain]:
		return active_behaviors[domain].get_class() == state_class
	return false
