@tool
extends VBoxContainer
class_name StatePanel

@onready var header_button: Button = $HeaderButton
@onready var collapsible_content: VBoxContainer = $CollapsibleContent
@onready var save_feedback_label: Label = $CollapsibleContent/SaveFeedbackLabel
@onready var save_feedback_timer: Timer = $CollapsibleContent/SaveFeedbackTimer

const ARROW_BIG_DOWN_DASH = preload("res://addons/statecafe/icons/arrow-big-down-dash.svg")
const ARROW_BIG_UP_DASH = preload("res://addons/statecafe/icons/arrow-big-up-dash.svg")

@export var state_config: StateConfig = preload("res://addons/statecafe/resources/state_config.tres")

var _is_expanded: bool = true
var _expanded_height: float = 0.0

func set_state_config(config: StateConfig):
	if state_config and state_config.is_connected("config_changed", Callable(self, "_show_save_feedback")):
		state_config.disconnect("config_changed", Callable(self, "_show_save_feedback"))
	state_config = config
	if state_config:
		state_config.connect("config_changed", Callable(self, "_show_save_feedback"))
	_load_config_to_ui()

func _show_save_feedback():
	save_feedback_label.visible = true
	save_feedback_timer.start()

func _ready():
	if Engine.is_editor_hint():
		_load_config_to_ui()
		_initialize_panel_state()
		header_button.pressed.connect(_on_header_button_pressed)
		save_feedback_timer.timeout.connect(_on_save_feedback_timer_timeout)

func _initialize_panel_state():
	collapsible_content.visible = true
	collapsible_content.custom_minimum_size.y = -1 
	_expanded_height = collapsible_content.size.y
	
	if state_config:
		_is_expanded = state_config.is_panel_expanded
		collapsible_content.visible = _is_expanded
		if _is_expanded:
			collapsible_content.custom_minimum_size.y = _expanded_height
			header_button.icon = ARROW_BIG_UP_DASH
		else:
			collapsible_content.custom_minimum_size.y = 0
			header_button.icon = ARROW_BIG_DOWN_DASH
	else:
		_is_expanded = true # Default to expanded if no config
		_update_panel_visibility()

func _load_config_to_ui():
	if not state_config: return
	_is_expanded = state_config.is_panel_expanded
	_update_panel_visibility()

func _on_header_button_pressed():
	_is_expanded = not _is_expanded
	if state_config:
		state_config.is_panel_expanded = _is_expanded
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	if _is_expanded:
		collapsible_content.visible = true
		tween.tween_property(collapsible_content, "custom_minimum_size:y", _expanded_height, 0.3)
		header_button.icon = ARROW_BIG_DOWN_DASH
	else:
		tween.tween_property(collapsible_content, "custom_minimum_size:y", 0, 0.3)
		tween.tween_callback(Callable(collapsible_content, "set_visible").bind(false))
		header_button.icon = ARROW_BIG_UP_DASH

func _update_panel_visibility():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	if _is_expanded:
		collapsible_content.visible = true
		tween.tween_property(collapsible_content, "custom_minimum_size:y", _expanded_height, 0.3)
		header_button.icon = ARROW_BIG_DOWN_DASH
	else:
		tween.tween_property(collapsible_content, "custom_minimum_size:y", 0, 0.3)
		tween.tween_callback(Callable(collapsible_content, "set_visible").bind(false))
		header_button.icon = ARROW_BIG_UP_DASH

func _on_save_feedback_timer_timeout():
	save_feedback_label.visible = false
