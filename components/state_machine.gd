@tool
extends Node

# This is a placeholder for StateMachine functionality.
# Add your manager logic here.

func _ready():
	if Engine.is_editor_hint():
		print("StateMachine is ready in editor.")
	else:
		print("StateMachine is ready in game.")
