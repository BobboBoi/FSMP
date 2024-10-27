extends VBoxContainer

func sort():
	var numb = 0
	for i in get_children():
		if i is MusicSelection:
			i.SetVariation(1+int(numb % 2 == 0))
		numb += 1
