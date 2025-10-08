@tool
extends Resource
class_name StateConfig

signal config_changed

@export var is_panel_expanded: bool = true:
	set(value):
		if is_panel_expanded != value:
			is_panel_expanded = value
			_save_and_emit_changed()

func _save_and_emit_changed():
	if self.resource_path:
		var dir = self.resource_path.get_base_dir()
		if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(dir)):
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
		
		var error = ResourceSaver.save(self, self.resource_path)
		if error != OK:
			push_error("Failed to save StateConfig resource: %s" % error)
	emit_changed()
	emit_signal("config_changed")
