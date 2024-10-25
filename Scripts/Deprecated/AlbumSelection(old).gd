extends Control

var albumName : String
var artists : Array
var cover : String

func init(coverPar : String, namePar : String ,artistsPar : Array):
	albumName = namePar
	artists = artistsPar
	$Name.text = namePar
	$Artist.text = str(artistsPar)
	if coverPar != "":
		var file = FileAccess.open(coverPar, FileAccess.READ)
		var bytes = file.get_buffer(file.get_length())
		var texture = Image.new()
		if bytes.size() > 0:
			if coverPar.ends_with(".png"):
				texture.load_png_from_buffer(bytes)
				print("Load succesful png:",texture)
			elif coverPar.ends_with(".jpg"):
				texture.load_jpg_from_buffer(bytes)
				print("Load succesful jpg:",texture)
			file.close()
			var final = ImageTexture
			final = final.create_from_image(texture)
			$TextureRect.texture = final
		else:
			file.close()
			print("Couldn't load cover for: ",coverPar)
	cover = coverPar
