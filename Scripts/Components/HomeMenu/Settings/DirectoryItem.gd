extends HomeMenuItem
class_name DirectoryItem

var dir := ""

static func Create(newDir : String) -> DirectoryItem:
	var loaded := preload("res://Scenes/Components/HomeMenu/Settings/DirectoryItem.tscn").instantiate()
	loaded.dir = newDir
	loaded.get_node("%Label").text = newDir
	return loaded

func ConnectButton(action : Callable) -> void:
	%Button.pressed.connect(action,CONNECT_DEFERRED)
