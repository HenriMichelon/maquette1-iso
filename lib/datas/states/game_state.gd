extends Node

signal saving_start()
signal saving_end()

var paused:bool = false
var current_zone:Zone
var quests = QuestsManager.new()
var location = LocationState.new()
var camera = CameraState.new()
var inventory = ItemsCollection.new()
var events_queue = EventsQueue.new()
var messages = MessagesList.new()
var settings = SettingsState.new()
var player:Player
var view_pivot:ViewPivot
var is_mobile:bool
var use_joypad = null

func _ready():
	is_mobile = OS.get_name() in ["android", "iOS"]
	var os_lang = OS.get_locale_language()
	for lang in Settings.langs:
		if (lang == os_lang):
			GameState.settings.lang = lang
	loadGame(StateSaver.get_last())
	TranslationServer.set_locale(GameState.settings.lang)

func saveGame(savegame = null):
	call_deferred("emit_signal","saving_start")
	StateSaver.set_path(savegame)
	StateSaver.saveState(settings)
	StateSaver.saveState(QuestsState.new(quests))
	StateSaver.saveState(MessagesState.new(messages))
	location.position = player.position
	location.rotation = player.rotation
	StateSaver.saveState(location)
	StateSaver.saveState(camera)
	StateSaver.saveState(InventoryState.new(inventory))
	StateSaver.saveState(EventsQueueState.new(events_queue))
	StateSaver.saveState(current_zone.state)
	call_deferred("emit_signal","saving_end")

func loadGame(savegame = null):
	StateSaver.set_path(savegame)
	StateSaver.loadState(settings)
	StateSaver.loadState(QuestsState.new(quests))
	StateSaver.loadState(MessagesState.new(messages))
	StateSaver.loadState(location)
	StateSaver.loadState(camera)
	StateSaver.loadState(InventoryState.new(inventory))
	StateSaver.loadState(EventsQueueState.new(events_queue))
	
func loadZone(zone_name:String):
	var zone_path = "res://zones/" + zone_name + ".tscn"
	ResourceLoader.load_threaded_request(zone_path)
	
func getZone(zone_name:String):
	var zone_path = "res://zones/" + zone_name + ".tscn"
	var _dummy = []
	if (ResourceLoader.load_threaded_get_status(zone_path, _dummy) == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE):
		ResourceLoader.load_threaded_request(zone_path)
	return ResourceLoader.load_threaded_get(zone_path)

func loadDialog(node, dialog, close_func = null):
	var scene = load("res://scenes/" + dialog + ".tscn").instantiate()
	add_child(scene)
	if (close_func != null): scene.connect("close", close_func)
	return scene

class MessagesState extends State:
	var messages:MessagesList
	func _init(_inv):
		super("messages")
		messages = _inv

class QuestsState extends State:
	var quests:QuestsManager
	func _init(_inv):
		super("quests")
		quests = _inv

class InventoryState extends State:
	var inventory:ItemsCollection
	func _init(_inv):
		super("inventory")
		inventory = _inv

class EventsQueueState extends State:
	var queue:EventsQueue
	func _init(_queue):
		super("events_queue")
		queue = _queue
