extends StaticBody3D
class_name Usable

signal using(is_used:bool)
@export var label:String

var is_used:bool = false
var save:bool

func _init(_save:bool = false):
	save = _save
	
func _ready():
	if (label == null): label = get_path()
	set_collision_layer_value(3, true)

func use():
	if (!is_used):
		_use()
	else:
		_unuse()
	is_used = !is_used
	using.emit(is_used)
		
func _use():
	pass

func _unuse():
	pass
