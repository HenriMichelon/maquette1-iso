extends CharacterBody3D
class_name InteractiveCharacter

@export var label:String
signal trade(char:InteractiveCharacter)
signal talk(char:InteractiveCharacter,phrase:String, answers:Array)
signal end_talk()

var discussion:Array
var current:Array
var items_list:Array
var items:ItemsCollection
var generate_chance:int

func _init(disc = ["Hello !", [["Bye.", _end]] ], it = [], gen = 0):
	discussion = disc
	items_list = it
	if (not items_list.is_empty()):
		items = ItemsCollection.new()
		generate_chance = gen

func _ready():
	set_collision_layer_value(5, true)
	var rng = RandomNumberGenerator.new()
	if (items != null) and ((rng.randi_range(0, generate_chance) == 1) or (items.count() == 0)):
		for item in items_list:
				var max_qty = 1
				if (item.size() == 3):
					max_qty = item[2]
				var qty = rng.randi_range(0, max_qty)
				if (qty > 0):
					items.new(item[0], item[1], qty)

func interact():
	say(discussion)
	
func _trade():
	trade.emit(self)
	
func say(disc):
	current = disc
	var phrase = current[0]
	var answr = current[1]
	if phrase is Array:
		var fun = phrase[1]
		if (phrase.size() == 3):
			var param = phrase[2]
			fun.call(param)
		else:
			fun.call()
		phrase = phrase[0]
	talk.emit(self, phrase, answr)
	
func _end():
	end_talk.emit()
	
func answer(index:int):
	var next = current[1][index]
	if (next is Callable):
		next = next.call()
	next = next[1]
	if (next is Callable):
		next = next.call()
	if next is Array:
		say(next)

func _to_string():
	return label
