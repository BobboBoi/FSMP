extends HomeMenuItem
class_name QueueSelection

@onready var list : SongList = get_parent()
@onready var panel : PanelContainer = %Panel
@export var musicIndex : int
@export var songName : String

func _ready() -> void:
	set_process(false)

static func Create(data : MusicData) -> QueueSelection:
	var loaded := preload("res://Scenes/Components/MediaControls/QueueSelection.tscn").instantiate()
	loaded.songName = data.name
	loaded.get_node("%Name").text = data.name
	loaded.get_node("%Artist").text = data.artist
	return loaded

func _process(_delta : float) -> void:
	var prevPos := panel.global_position
	panel.global_position = get_global_mouse_position() - size / 2
	
	if prevPos.y == panel.global_position.y: return
	
	var reverse = prevPos.y - panel.global_position.y > 0
	var items := list.get_children()
	var currentIndex := items.find(self)
	var newIndex := 0
	
	for index in range(items.size()):
		if reverse: index = items.size() - 1 - index
		var i := items[index]
		
		if index != currentIndex and ((i.global_position.y > get_global_mouse_position().y and !reverse) or (i.global_position.y < get_global_mouse_position().y and reverse)):
			break;
			
		newIndex = index
	
	if newIndex != currentIndex:
		list.move_child(self,newIndex)

func _on_button_button_down() -> void:
	panel.top_level = true
	panel.z_index = 1
	set_process(true)

func _on_button_button_up() -> void:
	panel.top_level = false
	panel.z_index = 0
	set_process(false)
	panel.position = Vector2.ZERO
