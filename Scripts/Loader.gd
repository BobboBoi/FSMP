extends Node

var config : Config
const configPath := "user://config.tres"

func _ready() -> void:
	var loaded = Load(configPath)
	if loaded == null or loaded is not Config:
		loaded = Config.new()
		Save(configPath,loaded)
		
		var popUp = load("uid://b4o7fatfc6nm0").instantiate()
		get_tree().get_first_node_in_group("ProgramRoot").add_child(popUp)
	
	config = loaded

func Save(path : String, nodeToSave):
	#print(nodeToSave," "+path+".tres")
	ResourceSaver.save(nodeToSave, path)

func Load(filePath : String, debug := false):
	if debug:
		print("Loading... ", filePath)
	
	if ResourceLoader.exists(filePath):
		return ResourceLoader.load(filePath)
	
	push_warning("Couldn't load: ",filePath)
	return null
