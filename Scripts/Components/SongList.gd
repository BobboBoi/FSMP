extends VBoxContainer
class_name SongList

@export var bookMarks := true

func Update():
	#Remove bookmarks
	for i in get_children():
		if i is Label and i.has_meta("BookMark"):
			i.queue_free()
	
	#Sort the list
	SortList()
	
	var numb = 0
	#Add final details
	for i in get_children():
		if bookMarks: numb = CheckBookmark(i,numb)
		
		#Add color patern
		if i is HomeMenuItem:
			i.SetVariation(1+int(numb % 2 == 0))
		
		numb += 1

func SortList() -> void:
	var items := get_children()
	var sorted := items
	sorted.sort_custom(SortItems)
	
	#Move items to new position in the list
	for i in items:
		move_child(i,sorted.find(i))

func SortItems(a,b) -> bool:
	if a is MusicSelection and b is MusicSelection:
		return a.data.name < b.data.name
	if a is QueueSelection and b is QueueSelection:
		return a.songName < b.songName
	if a is AlbumSelection and b is AlbumSelection:
		return a.data.name.to_lower() < b.data.name.to_lower()
	if a is Button and b is Button:
		return a.text < b.text
	
	push_warning(self.name,": Format not supported by list sorting")
	return false

##Check for a new starting character and add a book mark if true.[br]
##Returns the new child index.
func CheckBookmark(item,index : int) -> int:
	#Add a "#" at the start for all songs that start with a number
	if index == 0:
		add_child(NewBookmark("#"))
		move_child(get_child(get_child_count()-1),index)
		index += 1
	
	#Add a bookmark for a new starting letter
	elif !IsNumber(item.data.name):
		if get_child(index-1).data.name.substr(0,1) != item.data.name.substr(0,1):
			var letter := get_child(index).name.substr(0,1)
			add_child(NewBookmark(letter))
			move_child(get_child(get_child_count()-1),index)
			index += 1
	
	return index

func NewBookmark(letter : String) -> Label:
	var newMark := Label.new()
	newMark.text = letter
	newMark.set_meta("BookMark",null)
	newMark.name = "BookMark "+letter
	
	newMark.custom_minimum_size.y = 45
	newMark.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	
	return newMark

func IsNumber(par : String) -> bool:
	return par.substr(0,1).is_valid_int()
