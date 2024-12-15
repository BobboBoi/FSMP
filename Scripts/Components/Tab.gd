extends Control
class_name Tab

@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

signal TabOpened
signal TabClosed

func _init() -> void:
	visibility_changed.connect(_VisChange)

func _VisChange() -> void:
	if visible:
		OnTabOpened()
		TabOpened.emit()
	else:
		OnTabClosed()
		TabClosed.emit()

func OnTabOpened() -> void:
	pass

func OnTabClosed() -> void:
	pass
