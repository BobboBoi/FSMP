extends Button
class_name EnqueueButton
##Enqueues the current selection of the home menu

@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

func _ready() -> void:
	if !pressed.is_connected(OnPressed): pressed.connect(OnPressed)
	if !home.SelectionUpdated.is_connected(CheckSelection): home.SelectionUpdated.connect(CheckSelection)

func OnPressed() -> void:
	var data : Array[MusicData] = []
	for d in home.selected:
		if d is MusicSelection:
			data.append(d.data)
	
	var hideHome := Player.queue.size() <= 0
	Player.EnqueueFromDataArray(data)
	home.ClearSelection()
	if !hideHome: return
	home.HideHome()

func CheckSelection() -> void:
	if home.selected.size() <= 0: 
		hide()
		return
	
	if home.selected.front() is not MusicSelection:
		hide()
		return
	
	show()
