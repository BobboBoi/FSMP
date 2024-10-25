extends AnimatedSprite2D

@onready var p : Node = get_parent()

func _ready() -> void:
	play("Pug")
	
	if p is not Control: return
	if !p.resized.is_connected(SizeChanged): p.resized.connect(SizeChanged)

func SizeChanged():
	if p == null: return
	position = Vector2(p.size.x/2,p.size.y/2)
