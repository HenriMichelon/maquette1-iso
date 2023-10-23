extends Node3D

@export var labelInfo:Label
var items_transfert_dialog:ItemsTransfertDialog

func _ready():
	GameState.connect("saving_start", _on_saving_start)
	GameState.connect("saving_end", _on_saving_end)
	GameState.player = $Game/Player
	_on_change_zonelevel(GameState.location.zone_name, "default", false)
	if (GameState.location.position != Vector3.ZERO):
		_set_player_position(GameState.location.position, GameState.location.rotation)
	items_transfert_dialog = load("res://scenes/dialogs/items_transfert_dialog.tscn").instantiate()
	items_transfert_dialog.connect("close", _on_storage_close)
	items_transfert_dialog.connect("item_collected", _on_player_item_collected)
	#_on_button_inventory_pressed()
	
func _process(_delta):
	if (GameState.paused): return
	if Input.is_action_just_pressed("player_inventory"):
		_on_button_inventory_pressed()
	
func _set_player_position(pos:Vector3, rot:Vector3):
	GameState.player.position = pos
	GameState.player.rotation = rot
	$Game/CameraPivot/Camera.move(pos)

func _on_change_zonelevel(zone_name:String, spawnpoint_key:String, save:bool=true):
	if (save): GameState.saveGame()
	GameState.location.zone_name = zone_name
	if (GameState.current_zone != null): 
		GameState.player.disconnect("item_collected", GameState.current_zone.on_item_collected)
		GameState.current_zone.queue_free()
	GameState.current_zone = load("res://zones/" + zone_name + ".tscn").instantiate()
	GameState.current_zone.connect("change_zone", _on_change_zonelevel)
	GameState.player.connect("item_collected", GameState.current_zone.on_item_collected)
	$Game.add_child(GameState.current_zone)
	for node in GameState.current_zone.find_children("*", "SpawnPoint", false, true):
		if (node.key == spawnpoint_key):
			_set_player_position(node.position, node.rotation)
			break
	for node in GameState.current_zone.find_children("*", "Storage", true, true):
		node.connect("open", _on_storage_open)
			
func _on_storage_open(node:Storage):
	_on_pause(false)
	add_child(items_transfert_dialog)
	items_transfert_dialog.open(node)
	
func _on_storage_close():
	remove_child(items_transfert_dialog)
	_on_resume()

func _on_button_quit_pressed():
	GameState.saveGame()
	get_tree().quit()

func _on_button_inventory_pressed():
	_on_pause()
	var scene = load("res://scenes/inventory_screen.tscn").instantiate()
	add_child(scene)
	scene.connect("close", _on_resume)
	
func _on_pause(hidegame:bool=true):
	GameState.paused = true
	$Game/UI.visible = false
	$Game.visible = !hidegame
	
func _on_resume(from:Node=null):
	if (from != null): remove_child(from)
	$Game/UI.visible = true
	$Game.visible = true
	GameState.paused = false
	
func _on_saving_start():
	$Game/UI/LabelSaving.visible = true

func _on_saving_end():
	$Game/UI/LabelSaving/Timer.start()
	
func _on_saving_timer_timeout():
	$Game/UI/LabelSaving.visible = false

func _on_display_info(node:Node3D):
	labelInfo.text = str(node)
	labelInfo.visible = true

func _on_hide_info():
	labelInfo.visible = false
	labelInfo.text = ''

func _on_player_item_collected(item):
	GameState.inventory.add(item.duplicate())
