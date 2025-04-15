extends HomeMenuItem
class_name QueueSelection

@onready var content = preload("uid://muwqglgsr75o")
@onready var visNot := %VisNotifier
@export var queueIndex : int
@export var data : MusicData

signal ContentLoaded

static func Create(d : MusicData, qi : int) -> QueueSelection:
	var loaded := preload("uid://bj562ggiykkx7").instantiate()
	loaded.data = d
	loaded.queueIndex = qi
	return loaded

func _ready() -> void:
	super()
	await get_tree().process_frame
	if visNot.is_on_screen():
		var c := content.instantiate()
		add_child(c)
		c.Refresh(self,false)
		ContentLoaded.emit()
	
	visNot.screen_entered.connect(VisUpdate.bind(true))
	visNot.screen_exited.connect(VisUpdate.bind(false))

func VisUpdate(vis : bool) -> void:
	if vis:
		if get_child_count() > 1: return
		
		var c := content.instantiate()
		add_child(c)
		c.Refresh(self)
		ContentLoaded.emit()
	else:
		if get_child_count() > 1:
			get_child(1).free()
