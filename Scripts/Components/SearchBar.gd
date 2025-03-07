extends LineEdit
class_name SearchBar

@export var target : Control
@export var refreshPatterns := true
#var property := "name"

func _init() -> void:
	if !text_changed.is_connected(Filter):
		text_changed.connect(Filter)
	if !text_submitted.is_connected(Submitted):
		text_submitted.connect(Submitted.unbind(1))

func _gui_input(event: InputEvent) -> void:
	if !has_focus(): return
	if target is not SongList: return
	if !(event.is_action_pressed("ui_down") or event.is_action_pressed("ui_focus_next")): return
	
	get_window().set_input_as_handled()
	var butts = target.GetVisibleChildren()
	if butts.size() <= 0: return
	butts[0].grab_focus()

func Submitted() -> void:
	if target is not SongList: return
	
	var butts = target.GetVisibleChildren()
	if butts.size() <= 0: return
	butts[0].grab_focus()

func Filter(_value : String):
	if target == null: return
	for i in target.get_children():
		if i is MusicSelection or i is AlbumSelection:
			i.visible = !(i.data.name.to_lower().find(text.to_lower()) == -1 and not text == "")
		elif i is QuickAccessButton:
			i.visible = !(i.text.to_lower().find(text.to_lower()) == -1 and not text == "")
		elif i is Label:
			i.visible = text == ""
	
	if target is not SongList: return
	target.VariationUpdate()
