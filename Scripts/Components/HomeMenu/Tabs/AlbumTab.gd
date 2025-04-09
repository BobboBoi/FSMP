extends Tab

@onready var list := %AlbumList
@onready var search := %SearchBar

func _OnTabClosed():
	if list == null: return
	for i in list.get_children(): i.free()
	search.text = ""

func _OnTabOpened():
	for i in list.get_children(): i.free()
	
	var numb = 0
	#List Albums
	for i in Lister.albums:
		var butt := await AlbumSelection.Create(i, await Lister.LoadAlbumCover(i))
		list.add_child(butt)
		butt.ConnectToAlbum(home)
		
		#Connect selection signals
		butt.Selected.connect(home.SelectedItem.bind(butt),CONNECT_DEFERRED)
		butt.Unselected.connect(home.UnselectedItem.bind(butt),CONNECT_DEFERRED)
		list.Update()
		
		numb += 1
