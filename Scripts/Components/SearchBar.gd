extends TextEdit
class_name SearchBar

@export var target : Control
#var property := "name"

func _init() -> void:
	if text_changed.is_connected(Filter): return
	text_changed.connect(Filter)

func Filter():
	if target == null: return
	for i in target.get_children():
		if i is MusicSelection or i is AlbumSelection:
			i.visible = !(i.data.name.to_lower().find(text.to_lower()) == -1 and not text == "")
		elif i is QuickAccessButton:
			i.visible = !(i.text.to_lower().find(text.to_lower()) == -1 and not text == "")
		elif i is Label:
			i.visible = text == ""
