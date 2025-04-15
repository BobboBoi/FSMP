extends SongList
class_name CustomizableList

@export_range(0,100) var autoScrollSensitivity := 30.
@export var autoScrollSpeed := 20.
var scrollCont : ScrollContainer
var movingItem : HomeMenuItem = null
var placeholder : Control = null
var initialIndex := -1
var chosenIndex := -1
var scrollSpeed := 0.

signal MovedIndex(originalIndex : int,newIndex : int)
signal MovedItem(item : Control,newIndex : int)

func _ready() -> void:
	if get_parent() is ScrollContainer:
		scrollCont = get_parent()
	sort = false
	hidden.connect(CancelHold)

func Update():
	super()
	
	var items := get_children()
	for i in items:
		if i is HomeMenuItem:
			if !i.Held.is_connected(StartHolding):
				i.Held.connect(StartHolding.bind(i))

func _process(delta : float) -> void:
	if movingItem == null:
		scrollSpeed = 0.
		set_process(false)
		return
	
	if autoScrollSpeed != 0. and scrollCont != null:
		scrollCont.scroll_vertical += roundi(scrollSpeed*(1./60./delta))
	
	var prevPos := movingItem.global_position
	movingItem.global_position = get_global_mouse_position() - movingItem.size / 2
	
	if prevPos.y == movingItem.global_position.y and scrollSpeed == 0.: return
	
	if autoScrollSpeed != 0. and scrollCont != null:
		var scrollMargin := autoScrollSensitivity/100 * scrollCont.size.y
		var bottom := scrollCont.global_position.y + scrollCont.size.y
		var top := scrollCont.global_position.y
		var mouse := clampf(get_global_mouse_position().y,top-1,bottom-1)
		
		#Scroll Down
		if mouse > bottom-scrollMargin:
			scrollSpeed = autoScrollSpeed * smoothstep(bottom-scrollMargin,bottom,mouse)
		#Scroll Up
		elif mouse < top+scrollMargin:
			scrollSpeed = -autoScrollSpeed * smoothstep(top+scrollMargin,top,mouse)
		else:
			scrollSpeed = 0
	
	var reverse := prevPos.y - movingItem.global_position.y > 0
	var items := get_children()
	var currentIndex := items.find(placeholder)
	var newIndex := 0
	
	for index in range(items.size()):
		if reverse: index = items.size() - 1 - index
		var i := items[index]
		
		if index != currentIndex and ((i.global_position.y > get_global_mouse_position().y and !reverse) or (i.global_position.y < get_global_mouse_position().y and reverse)):
			break;
		
		newIndex = index
	
	if newIndex != currentIndex:
		chosenIndex = newIndex
		move_child(placeholder,newIndex)

##Called when a menu item is held
func StartHolding(newItem : HomeMenuItem) -> void:
	if newItem == null: return
	movingItem = newItem
	
	chosenIndex = get_children().find(movingItem)
	initialIndex = chosenIndex
	placeholder = CreatePlacHolder(movingItem)
	movingItem.add_sibling(placeholder)
	movingItem.reparent(placeholder)
	
	movingItem.top_level = true
	movingItem.z_index = 1
	movingItem.global_position = get_global_mouse_position() - movingItem.size / 2
	set_process(true)
	
	movingItem.Dropped.connect(Drop,CONNECT_ONE_SHOT)

##Called when held item is dropped
func Drop(pos := -1) -> void:
	movingItem.top_level = false
	movingItem.z_index = 0
	set_process(false)
	scrollSpeed = 0.
	
	movingItem.reparent(self)
	placeholder.free()
	move_child(movingItem,chosenIndex if pos == -1 else pos)
	
	if chosenIndex != initialIndex:
		MovedIndex.emit(initialIndex,chosenIndex)
		MovedItem.emit(movingItem,chosenIndex)
	
	placeholder = null
	movingItem = null
	chosenIndex = -1
	initialIndex = -1
	
	VariationUpdate()

func CancelHold() -> void:
	if movingItem == null: return
	Drop(initialIndex)

##Create the plac holder for the held item
func CreatePlacHolder(item : Control) -> Control:
	var p := Panel.new()
	p.custom_minimum_size = item.custom_minimum_size
	p.size = item.size
	return p
