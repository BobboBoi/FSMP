extends AnimatedSprite2D

@onready var part = preload("res://Scenes/particles.tscn")
@onready var p : Node = get_parent()

func _ready() -> void:
	play("Pug")
	
	if p is not Control: return
	if !p.resized.is_connected(SizeChanged): p.resized.connect(SizeChanged)

func SizeChanged():
	if p == null: return
	position = Vector2(p.size.x/2,p.size.y/2)

func Update(mod : float):
	if mod < 0.0:
		scale = Vector2(lerp(scale.x, 1.0, 0.4), lerp(scale.y, 1.0,0.4)) 
	else:
		scale = Vector2(lerp(scale.x, 1 + mod*0.75 ,0.4) , lerp(scale.y, 1 + mod*0.75,0.4)) 

func OnBeat():
	if $Timer.time_left > 0.0: return
	var particles = part.instantiate()
	particles.emitting = true
	add_child(particles)
	$Timer.start(0.1)
