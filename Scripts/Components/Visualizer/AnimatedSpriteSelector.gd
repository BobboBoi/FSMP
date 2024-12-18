extends OptionButton

@export var target : AnimatedSprite2D = null

func _ready() -> void:
	for i in range(item_count): remove_item(i)
	if target == null: return
	
	var numb := 0
	for i in target.sprite_frames.get_animation_names():
		self.add_item(i)
		if target.animation == i: self.select(numb)
		numb += 1 
	
	self.item_selected.connect(Selected)

func Selected(item : int):
	target.play(get_item_text(item))
