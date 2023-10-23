extends Usable
class_name Storage

signal open(node:Storage)

func _init():
	super(false)
	
func get_items() -> Array:
	return find_children("*", "Item", true, false)

func _on_child_entered_tree(node:Node):
	if (node is Item):
		node.disable()
	
func _ready():
	connect("child_entered_tree", _on_child_entered_tree)
	set_collision_layer_value(3, true)
	for item in find_children("*", "Item", true, true):
		item.disable()
	
func _use():
	if (is_used):
		is_used = false
		open.emit(self)
