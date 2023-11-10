@tool
extends StaticBody3D

@export var sign:Texture2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if (sign != null):
		var mat = StandardMaterial3D.new()
		mat.albedo_texture = sign
		$"Modern Monitor/Screen".set_surface_override_material(0, mat)

