extends Button
class_name QuickAccessButton
##Light weight button that plays music with just a path.
##
##Used for the [QuickAccessMenu].
##This uses less memory then [MusicSelection] but displays less info.

var path := ""

func _init(newData : MusicData) -> void:
	text_overrun_behavior = TextServer.OverrunBehavior.OVERRUN_TRIM_CHAR
	size_flags_horizontal = SizeFlags.SIZE_EXPAND_FILL
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	focus_mode = FocusMode.FOCUS_ALL
	
	path = newData.path
	if newData.name != "":
		text = newData.name
	else:
		text = newData.path

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("RightClick"):
		var rcm := get_tree().get_first_node_in_group("RightClickMenu")
		if rcm == null: return
		rcm.Open(self)
	elif event.is_action_pressed("EnqueueNext"):
		Player.EnqueueNextFromPathArray([path])
	elif event.is_action_pressed("Enqueue"):
		Player.EnqueueFromPathArray([path])

func ConnectToPlayer(menu : QuickAccessMenu):
	connect("pressed",Player.PlaySingleFromPath.bind(path))   
	connect("pressed",menu.OnListButtonPressed)
