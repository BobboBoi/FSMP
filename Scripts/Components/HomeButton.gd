extends Button
class_name HomeButton
##Opens the home menu
##
##I know shocker.

func _ready() -> void:
	var home : HomeMenu = get_tree().get_first_node_in_group("Home")
	if home == null: return
	pressed.connect(home.showHome)
