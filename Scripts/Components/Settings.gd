extends Control

@onready var fileDialog : FileDialog = %FileDialog
@onready var dirList := %List
@onready var directoryLabel := %DirectoryLabel

var currentState := STATES.MUSIC
enum STATES {
	MUSIC,
	EXCLUDE
}

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("HomeMenu"):
		CloseLayer()

func VisUpdate() -> void:
	if !is_inside_tree(): return
	if visible:
		ReloadAddMusic()
	else:
		for i in dirList.get_children(): 
			if i is DirectoryItem:
				i.free()

#region music folders
func ReloadAddMusic() -> void:
	currentState = STATES.MUSIC
	directoryLabel.text = "Music Folders"
	
	for i in dirList.get_children(): 
		if i is DirectoryItem:
			i.queue_free()
	
	for i in Loader.config.musicPaths:
		var n := DirectoryItem.Create(i)
		dirList.add_child(n)
		n.ConnectButton(RemoveMusicFolder.bind(i))
	
	dirList.Update()

func AddMusicFolder(dir : String):
	Loader.config.musicPaths.append(dir)
	fileDialog.dir_selected.disconnect(AddMusicFolder)
	ReloadAddMusic()
	
	await ReloadAndSaveChanges()

func RemoveMusicFolder(dir : String):
	Loader.config.musicPaths.remove_at(Loader.config.musicPaths.find(dir))
	ReloadAddMusic()
	
	await ReloadAndSaveChanges()
#endregion music folders

#region exclude folders
func ReloadExludeFolders() -> void:
	currentState = STATES.EXCLUDE
	directoryLabel.text = "Exclude Folders"
	
	for i in dirList.get_children(): 
		if i is DirectoryItem:
			i.queue_free()
	
	for i in Loader.config.excludePaths:
		var n := DirectoryItem.Create(i)
		dirList.add_child(n)
		n.ConnectButton(RemoveExcludeFolder.bind(i))
	
	dirList.Update()

func AddExcludeFolder(dir : String):
	Loader.config.excludePaths.append(dir)
	fileDialog.dir_selected.disconnect(AddExcludeFolder)
	ReloadExludeFolders()
	
	await ReloadAndSaveChanges()

func RemoveExcludeFolder(dir : String):
	Loader.config.excludePaths.remove_at(Loader.config.musicPaths.find(dir))
	ReloadExludeFolders()
	
	await ReloadAndSaveChanges()
#endregion exclude folders

func ReloadAndSaveChanges() -> void:
	await Lister.Reload()
	Loader._save("user://config",Loader.config.duplicate())

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

func OnColorRectInput(event: InputEvent) -> void:
	if event.is_action("ui_accept"):
		CloseLayer()

func RefreshLister() -> void:
	Lister.Reload()

func MusicFolderPressed() -> void:
	ReloadAddMusic()

func ExcludeFolderPressed() -> void:
	ReloadExludeFolders()

func OnAddPressed() -> void:
	if currentState == STATES.MUSIC:
		fileDialog.dir_selected.connect(AddMusicFolder)
	else:
		fileDialog.dir_selected.connect(AddExcludeFolder)
	
	fileDialog.show()

func OnFileDialogCanceled() -> void:
	if fileDialog.dir_selected.is_connected(AddMusicFolder):
		fileDialog.dir_selected.disconnect(AddMusicFolder)
	if fileDialog.dir_selected.is_connected(AddExcludeFolder):
		fileDialog.dir_selected.disconnect(AddExcludeFolder)
