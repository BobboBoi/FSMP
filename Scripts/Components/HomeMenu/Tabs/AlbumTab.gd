extends Tab

@onready var list := %AlbumList
@onready var search := %SearchBar

func _ready():
	Lister.ListChanged.connect(%LoadingSpinner.hide)
	Lister.ReloadStarted.connect(%LoadingSpinner.show.unbind(1))
	
	Lister.ListChanged.connect(%Scroll.show)
	Lister.ReloadStarted.connect(%Scroll.hide.unbind(1))

func _OnTabClosed():
	if Lister.ListChanged.is_connected(_OnTabOpened):
		Lister.ListChanged.disconnect(_OnTabOpened)
	
	if list == null: return
	for i in list.get_children(): i.free()
	search.text = ""

func _OnTabOpened():
	if !Lister.ListChanged.is_connected(_OnTabOpened):
		Lister.ListChanged.connect(_OnTabOpened)
	
	for i in list.get_children(): i.free()
	
	#List Albums
	for i in Lister.albums:
		var butt := AlbumSelection.Create(i)
		list.add_child(butt)
		butt.ConnectToAlbum(home)
		
		#Connect selection signals
		butt.Selected.connect(home.SelectedItem.bind(butt),CONNECT_DEFERRED)
		butt.Unselected.connect(home.UnselectedItem.bind(butt),CONNECT_DEFERRED)
	
	list.Update()
