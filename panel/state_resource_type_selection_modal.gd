@tool
extends ConfirmationDialog
class_name StateResourceTypeSelectionModal

signal resource_type_selected(type_name)

@onready var item_list: ItemList = $VBoxContainer/ItemList

var base_resource_type: String = "StateBehavior"
var script_path_prefix: String = "res://addons/state_machine/scripts/"

func _ready():
	_populate_item_list()

func _populate_item_list():
	item_list.clear()
	var dir = DirAccess.open(script_path_prefix)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".gd"):
				var script_path = script_path_prefix + file_name
				var script = load(script_path)
				if script and script is Script and ClassDB.is_parent_class(script.get_instance_base_type(), base_resource_type):
					item_list.add_item(script.resource_path.get_file().get_basename()) # Adiciona o nome da classe/arquivo
			file_name = dir.get_next()
	else:
		push_error("Não foi possível abrir o diretório de scripts: " + script_path_prefix)

func _on_confirmed():
	var selected_items = item_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_index = selected_items[0]
		var selected_type_name = item_list.get_item_text(selected_index)
		resource_type_selected.emit(selected_type_name)
	else:
		push_error("Nenhum tipo de recurso selecionado.")

func _on_item_list_item_activated(index: int):
	_on_confirmed()
