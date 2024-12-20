@tool
extends Control
class_name SpinyDisc

@export var speed := 120.
@export var pad := 50. :
	set(value):
		pad = value
		SizeUpdate()
@export var spinning := true :
	set(value):
		set_process(value)
		spinning = value

func _ready() -> void:
	SizeUpdate()

func _process(delta: float) -> void:
	if get_child_count() <= 0: return
	%Texture.rotation_degrees += speed * delta

func SizeUpdate() -> void:
	if get_child_count() <= 0: return
	var target : TextureRect = get_child(0)
	var shortSide := size.x if size.x < size.y else size.y
	shortSide *= shortSide
	shortSide = sqrt(shortSide + shortSide)
	
	var result := Vector2(shortSide,shortSide) /2
	
	target.custom_minimum_size = result + (Vector2(pad,pad) * (result/target.texture.get_size()))
	target.size = target.custom_minimum_size
	target.pivot_offset = target.size / 2
	target.position = size / 2 - target.size / 2
