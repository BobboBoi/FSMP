extends VBoxContainer

func sort():
	var numb = 0
	for i in get_children():
		if i is MusicSelection:
			if numb % 2 == 0:
				i.get_node("ColorRect").color = Color(0,0,0,1)
			else:
				i.get_node("ColorRect").color = Color(0.1,0.1,0.1,1)
		numb += 1
