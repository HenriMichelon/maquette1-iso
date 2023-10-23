extends Node3D
class_name Zone

signal change_zone(zone_name:String, spawnpoint_name:String)
@export var zone_name:String
var state:ZoneState = null

func _init(_state:ZoneState=null):
	if (state != null): state = _state.new(self)

func _ready():
	if (state == null) : state = ZoneState.new(zone_name, self)
	StateSaver.loadState(state)
	for i in range(state.items_removed.size()):
		var item = get_node(state.items_removed[i])
		if (item.owner is Storage):
			item.owner.items.remove(item)
		item.queue_free()
	for item in state.items_added.items: 
		if item.has_meta("parent"):
			var path = item.get_meta("parent").replace(str(get_path()) + "/", '')
			var parent = find_child(path)
			if (parent != null) and (parent is Storage):
				parent.add_child(item)
				parent.items.add(item)
		else:
			add_child(item)
	for trigger in find_children("*", "ZoneChangeTrigger", true, true):
		trigger.connect("triggered", on_zone_change)
	var event = GameState.events_queue.getNextEvent(zone_name)
	while (event != null):
		var node = get_node(event.target)
		if (node != null):
			node.call(event.event)
		event = GameState.events_queue.getNextEvent(zone_name)
	_zone_ready()

func _zone_ready():
	pass
	
func on_zone_change(trigger:ZoneChangeTrigger):
	change_zone.emit(trigger.zone_name, trigger.spawnpoint_key)
	
func on_item_dropped(item:Item):
	if (item.get_parent() == null):
		add_child(item)
	state.items_added.add(item)
	
func on_item_collected(item:Item):
	if (item.owner != null): # items from scene
		state.items_removed.append(item.get_path())
	else:
		state.items_added.remove(item)
	item.queue_free()
