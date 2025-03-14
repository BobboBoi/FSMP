extends Control
class_name QuickAccessMenu

@onready var lister : TrackLister = %TrackLister
@onready var player : Player = %Player
@onready var listButton := %ListButton
@onready var searchbar := %Searchbar
@onready var list := %List
@onready var root := %Root

func _ready() -> void:
	Reload()
	lister.ListChanged.connect(Reload)

func Reload() -> void:
	for i in list.get_children(): i.free()
	for i in lister.music:
		var butt := QuickAccessButton.new(i)
		butt.custom_minimum_size = Vector2(0,75)
		butt.ConnectToPlayer(player)
		list.add_child(butt)

func OnListButtonPressed() -> void:
	var tween := create_tween()
	if root.position.x == 0:
		tween.tween_property(root,"position",Vector2(-root.size.x as float,0),0.4)
		listButton.text = ">"
	else:
		tween.tween_property(root,"position",Vector2(0.0,0.0),0.4)
		listButton.text = "<"

func SearchBarTextChanged() -> void:
	for i in list.get_children():
		if i is QuickAccessButton:
			i.visible = !(i.text.to_lower().find(searchbar.text) == -1 and not searchbar.text == "")
