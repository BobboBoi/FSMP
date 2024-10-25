extends Control

@onready var fileDialog : FileDialog = %FileDialog
@onready var lister : TrackLister = get_tree().get_first_node_in_group("Lister")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if fileDialog.visible:
			fileDialog.hide()
			get_window().set_input_as_handled()
		elif %FirstTime.visible:
			%FirstTime.hide()
			get_window().set_input_as_handled()
		elif self.visible:
			hide()
			get_window().set_input_as_handled()

func MFolderPressed() -> void:
	fileDialog.dir_selected.connect(AddMusicFolder)
	fileDialog.show()

func CFolderPressed() -> void:
	fileDialog.dir_selected.connect(SetCoverFolder)
	fileDialog.show()

func AddMusicFolder(dir : String):
	Loader.config.musicPaths.append(dir)
	Loader._save("user://config",Loader.config)
	lister.Reload()
	fileDialog.dir_selected.disconnect(AddMusicFolder)


func SetCoverFolder(dir : String):
	Loader.config.coverPath = dir+"\\"
	Loader._save("user://config",Loader.config)
	fileDialog.dir_selected.disconnect(SetCoverFolder)


func OnCancel() -> void:
	if fileDialog.dir_selected.is_connected(AddMusicFolder):
		fileDialog.dir_selected.disconnect(AddMusicFolder)
	if fileDialog.dir_selected.is_connected(SetCoverFolder):
		fileDialog.dir_selected.disconnect(SetCoverFolder)
