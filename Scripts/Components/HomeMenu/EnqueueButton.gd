extends Button

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var home : HomeMenu = get_tree().get_first_node_in_group("Home")

func OnPressed() -> void:
	var data : Array[MusicData] = []
	for d in home.selected:
		if d is MusicSelection:
			data.append(d.data)
	
	player.EnqueueFromDataArray(data)
	home.ClearSelection()

func CheckSelection() -> void:
	if home.selected.size() <= 0: 
		hide()
		return
	
	if home.selected.front() is not MusicSelection:
		hide()
		return
	
	show()
