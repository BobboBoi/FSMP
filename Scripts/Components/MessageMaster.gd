extends Control
class_name MessageMaster

func _ready() -> void:
	if Loader.config.musicPaths.size() == 0:
		TextMessage("No music folder has been set! Please add a folder in the settings")
	if Loader.config.coverPath == "":
		TextMessage("No cover folder has been set! Please set a folder in the settings")

func TextMessage(txt : String,time := 5.0):
	var msg = Message.Create(txt,time)
	$VCont.add_child(msg)
