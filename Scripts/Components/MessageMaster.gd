extends Control
class_name MessageMaster

func _ready() -> void:
	if Loader.config.musicPaths.size() == 0:
		TextMessage("No music folder has been set! Please add a folder in the settings")

func TextMessage(txt : String,time := 5.0):
	if !is_inside_tree():
		await ready
	var msg = Message.Create(txt,time)
	%MsgCont.add_child(msg)
