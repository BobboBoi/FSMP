extends Tab

@onready var lister : TrackLister
@onready var list := %AlbumList
@onready var search := %SearchBar

func _OnTabClosed():
	if list == null: return
	for i in list.get_children(): i.free()
	search.text = ""

func _OnTabOpened():
	for i in list.get_children(): i.free()
	
	if lister == null:
		lister = home.lister
	
	var numb = 0
	#List Albums
	for i in lister.albums:
		var butt := AlbumSelection.Create(i,home.lister.LoadAlbumCover(i))
		list.add_child(butt)
		butt.ConnectToAlbum(home)
		
		#Connect selection signals
		butt.Selected.connect(home.SelectedItem.bind(butt),CONNECT_DEFERRED)
		butt.Unselected.connect(home.UnselectedItem.bind(butt),CONNECT_DEFERRED)
		
		if(numb % 20 == 0):
			list.Update()
			await get_tree().process_frame
		
		numb += 1
	
	list.Update()
