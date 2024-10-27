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
	
	path = newData.name
	if newData.name != "":
		text = newData.name
	else:
		text = newData.path

func ConnectToPlayer(player : Player):
	connect("pressed",player.PlayFromPath.bind("user://Songs/"+path))   
