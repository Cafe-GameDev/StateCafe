@tool
extends Control
class_name StateBottomPanel

@onready var create_button = $"VBoxContainer/HBoxContainer/CreateButton"
@onready var remove_button = $"VBoxContainer/HBoxContainer/RemoveButton"
@onready var edit_script_button = $"VBoxContainer/HBoxContainer/EditScriptButton"
@onready var item_list = $"VBoxContainer/ItemList"

func _ready():
	if Engine.is_editor_hint():
		create_button.pressed.connect(_on_create_button_pressed)
		remove_button.pressed.connect(_on_remove_button_pressed)
		edit_script_button.pressed.connect(_on_edit_script_button_pressed)
		item_list.item_activated.connect(_on_item_list_item_activated)
		
		_populate_item_list()

func _populate_item_list():
	item_list.clear()
	var dir = DirAccess.open("res://addons/state_machine/resources/state_behaviors/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				item_list.add_item(file_name)
			file_name = dir.get_next()
	else:
		push_error("Não foi possível abrir o diretório de recursos: res://addons/state_machine/resources/state_behaviors/")

func _on_create_button_pressed():
	var file_dialog = FileDialog.new()
	file_dialog.title = "Criar Novo StateBehavior"
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dialog.access = FileDialog.ACCESS_RESOURCES
	file_dialog.current_path = "res://addons/state_machine/resources/state_behaviors/"
	file_dialog.add_filter("*.tres;Resource File", "*.tres")
	file_dialog.confirmed.connect(func():
		var save_path = file_dialog.current_path
		if not save_path.ends_with(".tres"):
			save_path += ".tres"
		
		# TODO: Substituir Resource.new() por uma instância de StateBehavior
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

func _on_remove_button_pressed():
	var selected_items = item_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[0]
		var selected_item_name = item_list.get_item_text(selected_index)
		var resource_path = "res://addons/state_machine/resources/state_behaviors/" + selected_item_name

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

func _on_edit_script_button_pressed():
	var selected_items = item_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[0]
		var selected_item_name = item_list.get_item_text(selected_index)
		var resource_path = "res://addons/state_machine/resources/state_behaviors/" + selected_item_name
		var resource = ResourceLoader.load(resource_path)

		if resource and resource.get_script() and resource.get_script() is Script:
			EditorInterface.edit_resource(resource.get_script())
		else:
			print("O recurso selecionado não possui um script associado ou o script não é válido.")
	else:
		print("Nenhum recurso selecionado para editar o script.")

func _on_item_list_item_activated(index: int):
	var selected_item_name = item_list.get_item_text(index)
	var resource_path = "res://addons/state_machine/resources/state_behaviors/" + selected_item_name
	var resource = ResourceLoader.load(resource_path)
	if resource:
		EditorInterface.edit_resource(resource)
	else:
		push_error("Não foi possível carregar o recurso: " + resource_path)

func _get_drag_data(position: Vector2):
	var selected_items = item_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[0]
		var selected_item_name = item_list.get_item_text(selected_index)
		var resource_path = "res://addons/state_machine/resources/state_behaviors/" + selected_item_name
		
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

