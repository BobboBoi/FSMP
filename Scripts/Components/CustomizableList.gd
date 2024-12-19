extends SongList
class_name CustomizableList

var movingItem : HomeMenuItem = null
var placeholder : Control = null
var initialIndex := -1
var chosenIndex := -1

signal MovedIndex(originalIndex : int,newIndex : int)
signal MovedItem(item : Control,newIndex : int)

func _ready() -> void:
	sort = false
	hidden.connect(CancelHold)

func Update():
	super()
	
	var items := get_children()
	for i in items:
		if i is HomeMenuItem:
			if !i.Held.is_connected(StartHolding):
				i.Held.connect(StartHolding.bind(i))

func _process(_delta : float) -> void:
	if movingItem == null:
		set_process(false)
		return
	
	var prevPos := movingItem.global_position
	movingItem.global_position = get_global_mouse_position() - movingItem.size / 2
	
	if prevPos.y == movingItem.global_position.y: return
	
	var reverse = prevPos.y - movingItem.global_position.y > 0
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
	
	movingItem.reparent(self)
	placeholder.free()
	move_child(movingItem,chosenIndex if pos == -1 else pos)
	
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
