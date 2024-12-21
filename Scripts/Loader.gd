extends Node

var config : Config

func _ready() -> void:
	var loaded = _load("user://config")
	if loaded == null or loaded is not Config:
		loaded = Config.new()
		_save("user://config",loaded)
		
		var popUp = load("res://Scenes/Components/FirstTime.tscn").instantiate()
		get_tree().get_first_node_in_group("ProgramRoot").add_child(popUp)
	
	config = loaded

func _save(path,nodeToSave):
	var dir = DirAccess.open("C:/")
	if not dir.dir_exists("user://Albums"):
		DirAccess.make_dir_recursive_absolute("user://Albums")
	
	print(nodeToSave," "+path+".tres")
	ResourceSaver.save(nodeToSave,path+".tres")

func _load(loadFile,debug = false):
	if debug:
		print("loading... "+loadFile+".tres")
	if ResourceLoader.exists(loadFile+".tres"):
		return ResourceLoader.load(loadFile+".tres")
	print("WARNING Couldn't load: ",loadFile+".tres")
	return null

func getFiles(path : String):
	if DirAccess.dir_exists_absolute(path):
		var dir = DirAccess.open(path)
		print(DirAccess.get_open_error()," | ",DirAccess.dir_exists_absolute(path))
		var files = []
		
		dir.list_dir_begin()
		
		while true:
			var file = dir.get_next()
			if file == "":
				break
			else:
				files.append(file)
		
		dir.list_dir_end()
		return files
	return null
