@tool
extends ConfirmationDialog
class_name StateResourceTypeSelectionModal

signal resource_type_selected(type_name)

@onready var item_list: ItemList = $VBoxContainer/ItemList

var base_resource_type: String = "StateBehavior"

func _ready():
	_populate_item_list()

func _populate_item_list():
	item_list.clear()
	var classes = ClassDB.get_known_classes_from_base(base_resource_type)
	for class_name in classes:
		item_list.add_item(class_name)

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