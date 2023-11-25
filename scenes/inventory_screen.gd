extends Control

class InventoryScreenState extends State:
	var tab:int = 0
	func _init():
		super("inventory_screen")

signal close(node:Node)
signal item_dropped(item:Item,quantity:int)

@onready var tabs:TabContainer = $Content/Body/Content/Tabs
@onready var list_tools:ItemList = $Content/Body/Content/Tabs/Tools/List
@onready var list_consumables:ItemList = $Content/Body/Content/Tabs/Consumables/List
@onready var list_quest:ItemList = $Content/Body/Content/Tabs/Quests/List
@onready var list_miscellaneous:ItemList = $Content/Body/Content/Tabs/Miscellaneous/List
@onready var item_content = $Content/Body/Content/PanelItem/Content
@onready var item_title = $Content/Body/Content/PanelItem/Content/Title
@onready var weigth_value = $Content/Body/Content/PanelItem/Content/LabelWeight
@onready var node_3d = $"Content/Body/Content/PanelItem/Content/ViewContent/3DView/InsertPoint"

const tab_order = [ 
	Item.ItemType.ITEM_TOOLS, 
	Item.ItemType.ITEM_CONSUMABLES,
	Item.ItemType.ITEM_MISCELLANEOUS,
	Item.ItemType.ITEM_QUEST
]

@onready var list_content = {
	Item.ItemType.ITEM_TOOLS : list_tools,
	Item.ItemType.ITEM_CONSUMABLES : list_consumables,
	Item.ItemType.ITEM_MISCELLANEOUS : list_miscellaneous,
	Item.ItemType.ITEM_QUEST : list_quest
}

var state = InventoryScreenState.new()
var item:Item
var list:ItemList
var selected = 0

func _ready():
	var ratio = size.x / size.y
	var vsize = get_viewport().size / get_viewport().content_scale_factor
	size.x = vsize.x / (1.5 if vsize.x > 1200 else 1.2)
	size.y = size.x / ratio
	position.x = (vsize.x - size.x) / 2
	position.y = (vsize.y - size.y) / 2
	tabs.custom_minimum_size.x = size.x/2
	StateSaver.loadState(state)
	tabs.current_tab = state.tab
	for type in list_content: _fill_list(type, list_content[type])
	connect("item_dropped", GameState.current_zone.on_item_dropped)

func _on_button_back_pressed():
	close.emit(self)

func _on_list_tools_item_selected(index):
	list_consumables.deselect_all()
	list_miscellaneous.deselect_all()
	list_quest.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_TOOLS), index)

func _on_list_miscellaneous_item_selected(index):
	list_consumables.deselect_all()
	list_quest.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_MISCELLANEOUS), index)

func _on_list_item_quest_selected(index):
	list_consumables.deselect_all()
	list_miscellaneous.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_QUEST), index)

func _on_list_item_consumable_selected(index):
	list_miscellaneous.deselect_all()
	list_quest.deselect_all()
	list_tools.deselect_all()
	_item_details(GameState.inventory.getone_bytype(index, Item.ItemType.ITEM_CONSUMABLES), index)

func _item_details(_item:Item, index):
	selected = index
	item = _item
	item_title.text = item.label
	weigth_value.text = tr("Weigth : %.2f") % _item.weight
	for c in node_3d.get_children():
		c.queue_free()
	var clone = _item.duplicate()
	node_3d.add_child(clone)
	clone.position = Vector3.ZERO
	clone.scale = clone.scale * (clone.preview_scale+1)
	item_content.visible = true

func _process(_delta):
	if ($SelectQuantityDialog.visible): return
	if (Input.is_action_just_pressed("cancel") or Input.is_action_just_pressed("player_inventory")):
		_on_button_back_pressed()
		return
	elif Input.is_action_just_pressed("delete"):
		_on_drop_pressed()
		return
	state.tab = tabs.current_tab
	if Input.is_action_just_pressed("ui_left"):
		state.tab -= 1
		_set_tab()
	elif Input.is_action_just_pressed("ui_right"):
		state.tab += 1
		_set_tab()
	elif Input.is_action_just_pressed("ui_down"):
		var list = tabs.get_current_tab_control().find_child("List")
		if (!list.has_focus()): 
			list.grab_focus()
			if (list.item_count > 0):
				list.select(0)
				list.item_selected.emit(0)

func _set_tab():
	if (state.tab < 0):
		state.tab = 4
	elif (state.tab > 4):
		state.tab = 0
	tabs.current_tab = state.tab
	item_content.visible = false
	StateSaver.saveState(state)

func _fill_list(type:Item.ItemType, list:ItemList):
	list.clear()
	for item in GameState.inventory.getall_bytype(type):
		list.add_item(tr(str(item)))

func _on_drop_pressed():
	if (item == null): return
	if (item is ItemMultiple):
		$SelectQuantityDialog.open(item, tr("Drop"), false)
	else:
		_drop()

func _drop(quantity:int=0):
	item_dropped.emit(item, quantity)
	_refresh()

func _refresh():
	item_content.visible = false
	_fill_list(item.type, list_content[item.type])
	
func _on_tabs_tab_selected(tab):
	list = list_content[tab_order[tab]]
	if (tab == state.tab): return
	state.tab = tab
	StateSaver.saveState(state)

