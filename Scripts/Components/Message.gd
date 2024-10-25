extends Control
class_name Message

var text := ""
var time := 5.0

static func Create(newText : String,newTime := 5.0) -> Message:
	var inst = preload("res://Scenes/Components/Message.tscn").instantiate()
	inst.time = newTime
	inst.text = newText
	return inst;

func _ready() -> void:
	Refresh()

func Refresh() -> void:
	%Label.text = text
	%Timer.start(time)
