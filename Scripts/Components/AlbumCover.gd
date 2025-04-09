@tool
extends PanelContainer
class_name AlbumCover

@export var sizeMode : SIZE_MODES :
	set(value):
		sizeMode = value
		SizeUpdate()
@export var texture : Texture2D :
	set(value):
		texture = value
		if get_node_or_null("%Texture") == null: return
		%Texture.texture = texture
var fadeTween : Tween


enum SIZE_MODES {
	FIT_HEIGHT,
	FIT_WIDTH
}

const TEXTURE_PADDING = 1.04

func FadeIn(t : ImageTexture, speed := 0.3) -> void:
	if fadeTween:
		fadeTween.kill()
	
	texture = t
	%Texture.modulate = Color(1,1,1,0)
	
	fadeTween = create_tween()
	fadeTween.tween_property(%Texture, "modulate", Color(1,1,1,1), speed)

func SizeUpdate() -> void:
	match(sizeMode):
		SIZE_MODES.FIT_HEIGHT:
			custom_minimum_size = Vector2(size.y,0.)
			size = Vector2(size.y,size.y)
		SIZE_MODES.FIT_WIDTH:
			custom_minimum_size = Vector2(0.,size.x)
			size = Vector2(size.x,size.x)
