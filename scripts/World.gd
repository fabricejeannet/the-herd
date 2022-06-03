extends Node2D

var Log = Logger.get_logger("World.gd")
var Zombie = preload("res://scenes/Zombie.tscn")
var HumanBeing = preload("res://scenes/HumanBeing.tscn")
var herd  = []

export var zombie_count:int = 10

onready var rows = $TileMap.get_used_rect().size.y
onready var cols = $TileMap.get_used_rect().size.x
onready var margin = max($TileMap.cell_size.x, $TileMap.cell_size.y)


func _ready():
	#Log.debug("Instanciating " + str(zombie_count) + " zombies", "_ready")
	for i in zombie_count:
		var zombie = Zombie.instance()
		zombie.set_id(i)
		zombie.connect("prey_detected", self, "_on_prey_detected")
		place_on_tile_map(zombie)
		herd.append(zombie)
		add_child(zombie)


func place_on_tile_map(zombie) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var cell_is_full = true
	var xpos:int 
	var ypos:int
	while (cell_is_full) :
		xpos = rng.randi_range(margin, int(get_viewport().size.x) - margin)
		ypos = rng.randi_range(margin, int(get_viewport().size.y) - margin)
		cell_is_full = $TileMap.get_cellv($TileMap.world_to_map(Vector2(xpos, ypos))) != $TileMap.INVALID_CELL	
	zombie.position = Vector2(xpos, ypos)


func _unhandled_input(event):
	if event is InputEventMouseButton and  event.button_index == BUTTON_LEFT and event.pressed:
		var human = HumanBeing.instance()
		human.position = get_global_mouse_position()
		add_child(human)


func _on_prey_detected(zombie_emitter, prey) -> void:
	for zombie in herd:
		if zombie == zombie_emitter:
			zombie.show_aggro_range()
			zombie.consider_targetting(prey)
		elif zombie.position.distance_to(zombie_emitter.position) < zombie_emitter.aggro_range:
			#Log.debug("Zombie #" + str(zombie_emitter.get_id()) + " have heard the signal")
			zombie.consider_targetting(prey)
