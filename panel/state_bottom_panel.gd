@tool
extends Control
class_name StateBottomPanel

@onready var create_resource_button: Button = $HBoxContainer/ResourceContainer/HBoxContainer/CreateResourceButton
@onready var remove_resource_button: Button = $HBoxContainer/ResourceContainer/HBoxContainer/RemoveResourceButton
@onready var edit_resource_button: Button = $HBoxContainer/ResourceContainer/HBoxContainer/EditResourceButton
@onready var resource_item_list: ItemList = $HBoxContainer/ResourceContainer/ResourceItemList

@onready var create_script_button: Button = $HBoxContainer/ScriptContainer/HBoxContainer/CreateScriptButton
@onready var remove_script_button: Button = $HBoxContainer/ScriptContainer/HBoxContainer/RemoveScriptButton
@onready var edit_script_button: Button = $HBoxContainer/ScriptContainer/HBoxContainer/EditScriptButton
@onready var script_item_list: ItemList = $HBoxContainer/ScriptContainer/ScriptItemList


func _ready():
	_populate_item_list()

func _populate_item_list():
	resource_item_list.clear()
	var resource_files = _get_files_recursive("res://addons/state_machine/resources/", ".tres")
	for file_path in resource_files:
		resource_item_list.add_item(file_path.replace("res://addons/state_machine/resources/", ""))

	script_item_list.clear()
	var script_files = _get_files_recursive("res://addons/state_machine/scripts/", ".gd")
	for script_path in script_files:
		var script = load(script_path)
		if script and script is Script and ClassDB.is_parent_class(script.get_instance_base_type(), "Resource"):
			script_item_list.add_item(script_path.replace("res://addons/state_machine/scripts/", ""))

func _on_create_resource_button_pressed():
	var file_dialog = FileDialog.new()
	file_dialog.title = "Criar Novo Resource"
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.current_path = "res://addons/state_machine/resources/"
	file_dialog.add_filter("*.tres;Resource File", "*.tres")
	file_dialog.confirmed.connect(func():
		var save_path = file_dialog.current_path
		if not save_path.ends_with(".tres"):
			save_path += ".tres"
		
		var new_resource = Resource.new() 

		var error = ResourceSaver.save(new_resource, save_path)
		if error == OK:
			_populate_item_list()
			print("Recurso criado: " + save_path)
		else:
			push_error("Erro ao criar o recurso: " + save_path + " (Erro: " + str(error) + ")")
	)
	get_tree().root.add_child(file_dialog)
	file_dialog.popup_centered()

func _on_remove_resource_button_pressed():
	var selected_items = resource_item_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[0]
		var selected_item_name = resource_item_list.get_item_text(selected_index)
		var resource_path = "res://addons/state_machine/resources/" + selected_item_name

		var dialog = ConfirmationDialog.new()
		dialog.dialog_text = "Tem certeza que deseja remover o recurso '" + selected_item_name + "'?"
		dialog.confirmed.connect(func():
			var error = DirAccess.remove_absolute(resource_path)
			if error == OK:
				_populate_item_list()
				print("Recurso removido: " + resource_path)
			else:
				push_error("Erro ao remover o recurso: " + resource_path + " (Erro: " + str(error) + ")")
		)
		get_tree().root.add_child(dialog)
		dialog.popup_centered()
	else:
		print("Nenhum recurso selecionado para remover.")

func _on_edit_resource_button_pressed():
	var selected_items = resource_item_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[0]
		var selected_item_name = resource_item_list.get_item_text(selected_index)
		var resource_path = "res://addons/state_machine/resources/" + selected_item_name
		var resource = ResourceLoader.load(resource_path)

		if resource:
			var modal = load("res://addons/state_machine/panel/state_modal_panel.tscn").instantiate()
			modal.set_resource(resource) # Assumindo que o modal tem um método set_resource
			get_tree().root.add_child(modal)
			modal.popup_centered()
		else:
			push_error("Não foi possível carregar o recurso: " + resource_path)
	else:
		print("Nenhum recurso selecionado para editar.")

func _on_resource_item_list_item_activated(index: int):
	var selected_item_name = resource_item_list.get_item_text(index)
	var resource_path = "res://addons/state_machine/resources/" + selected_item_name
	var resource = ResourceLoader.load(resource_path)
	if resource:
		EditorInterface.edit_resource(resource)
	else:
		push_error("Não foi possível carregar o recurso: " + resource_path)

func _get_drag_data(position: Vector2):
	var selected_items = resource_item_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[0]
		var selected_item_name = resource_item_list.get_item_text(selected_index)
		var resource_path = "res://addons/state_machine/resources/" + selected_item_name
		
		var preview = TextureRect.new()
		preview.texture = EditorInterface.get_base_control().get_theme_icon("Resource", "EditorIcons")
		preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		preview.custom_minimum_size = Vector2(32, 32)
		
		var drag_data = {
			"type": "resource_path",
			"path": resource_path
		}
		
		var control = Control.new()
		control.add_child(preview)
		set_drag_preview(control)
		
		return drag_data
	return null


func _on_create_script_button_pressed() -> void:
	var file_dialog = FileDialog.new()
	file_dialog.title = "Criar Novo Script de StateBehavior"
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.current_path = "res://addons/state_machine/scripts/"
	file_dialog.add_filter("*.gd;GDScript File", "*.gd")
	file_dialog.confirmed.connect(func():
		var save_path = file_dialog.current_path
		if not save_path.ends_with(".gd"):
			save_path += ".gd"
		
		var script_template = """
extends StateBehavior
class_name NewStateBehavior

func _init():
	state_name = "NewStateBehavior"

func _enter():
	# Lógica de entrada do estado
	pass

func _exit():
	# Lógica de saída do estado
	pass

func _process_state(delta: float):
	# Lógica de processamento do estado
	pass

func _physics_process_state(delta: float):
	# Lógica de processamento físico do estado
	pass
"""
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		if file:
			file.store_string(script_template)
			file.close()
			_populate_item_list()
			EditorInterface.edit_resource(load(save_path))
			print("Script criado: " + save_path)
		else:
			push_error("Erro ao criar o script: " + save_path)
	)
	get_tree().root.add_child(file_dialog)
	file_dialog.popup_centered()


func _on_remove_script_button_pressed() -> void:
	var selected_items = script_item_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[0]
		var selected_item_name = script_item_list.get_item_text(selected_index)
		var script_path = "res://addons/state_machine/scripts/" + selected_item_name

		var dialog = ConfirmationDialog.new()
		dialog.dialog_text = "Tem certeza que deseja remover o script '" + selected_item_name + "'?"
		dialog.confirmed.connect(func():
			var error = DirAccess.remove_absolute(script_path)
			if error == OK:
				_populate_item_list()
				print("Script removido: " + script_path)
			else:
				push_error("Erro ao remover o script: " + script_path + " (Erro: " + str(error) + ")")
		)
		get_tree().root.add_child(dialog)
		dialog.popup_centered()
	else:
		print("Nenhum script selecionado para remover.")


func _on_edit_script_button_pressed() -> void:
	var selected_items = script_item_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[0]
		var selected_item_name = script_item_list.get_item_text(selected_index)
		var script_path = "res://addons/state_machine/scripts/" + selected_item_name
		EditorInterface.edit_resource(load(script_path))
	else:
		print("Nenhum script selecionado para editar.")

func _on_script_item_list_item_activated(index: int) -> void:
	var selected_item_name = script_item_list.get_item_text(index)
	var script_path = "res://addons/state_machine/scripts/" + selected_item_name
	EditorInterface.edit_resource(load(script_path))

func _get_files_recursive(path: String, extension: String) -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				files.append_array(_get_files_recursive(path.path_join(file_name), extension))
			elif file_name.ends_with(extension):
				files.append(path.path_join(file_name))
			file_name = dir.get_next()
	return files


func _on_refresh_button_pressed() -> void:
	pass # Replace with function body.
