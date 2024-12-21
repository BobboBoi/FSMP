extends Control

@onready var lister : TrackLister = get_tree().get_first_node_in_group("Lister")
@onready var fileDialog : FileDialog = %FileDialog
@onready var dirList := %List

func VisUpdate() -> void:
	if !is_inside_tree(): return
	if visible:
		Reload()
	else:
		for i in dirList.get_children(): 
			if i is DirectoryItem:
				i.free()

func Reload() -> void:
	for i in dirList.get_children(): 
		if i is DirectoryItem:
			i.queue_free()
	
	for i in Loader.config.musicPaths:
		var n := DirectoryItem.Create(i)
		dirList.add_child(n)
		n.ConnectButton(RemoveMusicFolder.bind(i))
	
	dirList.Update()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("HomeMenu"):
		CloseLayer()

func OnColorRectInput(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		CloseLayer()

func CloseLayer():
	if fileDialog.visible:
		fileDialog.hide()
		get_window().set_input_as_handled()
	elif %About.visible:
		%About.hide()
		get_window().set_input_as_handled()
	elif self.visible:
		hide()
		get_window().set_input_as_handled()

func RefreshLister() -> void:
	lister.Reload()

func MusicFolderPressed() -> void:
	fileDialog.dir_selected.connect(AddMusicFolder)
	fileDialog.show()

func OnCancel() -> void:
	if fileDialog.dir_selected.is_connected(AddMusicFolder):
		fileDialog.dir_selected.disconnect(AddMusicFolder)

func RemoveMusicFolder(dir : String):
	Loader.config.musicPaths.remove_at(Loader.config.musicPaths.find(dir))
	Reload()
	
	await get_tree().process_frame
	
	lister.Reload()
	Loader._save("user://config",Loader.config.duplicate())

func AddMusicFolder(dir : String):
	Loader.config.musicPaths.append(dir)
	Reload()
	
	fileDialog.dir_selected.disconnect(AddMusicFolder)
	
	await get_tree().process_frame
	
	lister.Reload()
	Loader._save("user://config",Loader.config.duplicate())
