extends VBoxContainer


#Unreadable art :')
func sort():
	for i in get_children():
		if i is Label:
			i.queue_free()
	var sorted = get_children()
	var finalSort : Array = []
	finalSort.resize(sorted.size())
	var numb = 0
	for i in sorted:
		finalSort[numb] = i.name
		numb += 1
	finalSort.sort()
	numb = 0
	for i in finalSort:
		var child = 0
		for j in get_children():
			if get_child(child).name == i:
				break
			child += 1
		move_child(get_child(child),numb)
		numb += 1
	numb = 0
	for i in get_children():
		if numb != 0:
			if !number(i.name):
				if get_child(numb-1).name.substr(0,1) != i.name.substr(0,1):
					var letter = Label.new()
					letter.text = get_child(numb).name.substr(0,1)
					add_child(letter)
					move_child(get_child(get_child_count()-1),numb)
					numb += 1
		else:
			var letter = Label.new()
			letter.text = "#"
			add_child(letter)
			move_child(get_child(get_child_count()-1),numb)
			numb += 1
		if numb % 2 == 0:
			get_child(numb).get_node("ColorRect").color = Color(0,0,0,1)
		else:
			get_child(numb).get_node("ColorRect").color = Color(0.1,0.1,0.1,1)
		numb += 1

func number(par : String) -> bool:
	return par.substr(0,1).is_valid_int()
