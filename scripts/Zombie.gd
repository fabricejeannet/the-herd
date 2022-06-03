extends KinematicBody2D

signal prey_detected

var Log = Logger.get_logger("Zombie.gd")
var _id
var _target:Node2D
var rng = RandomNumberGenerator.new()
var neighbours = []
var _show_aggro_range = false
var _roaming:bool = false
var _target_position:Vector2

export var current_speed:float = 0.0
export var max_speed:float = 50.0
export var acceleration_factor:float = 1.2
export var rotation_factor:float = 0.02
export var centering_factor:float = 0.5
export var aggro_range:float = 200.0


func _ready():
	rng.randomize()
	roam()


func _physics_process(delta):
	_compute_target_position()
	move_and_slide(get_linear_velocity(), Vector2(0.0, 0.0), false, 4)
	rotate(get_angle_to(_target_position) * rotation_factor)
	update()


func get_linear_velocity() :
	var linear_velocity = (_target_position - position).normalized() * current_speed	
	return linear_velocity


func _compute_target_position() -> void:
	var xs = 0.0
	var ys = 0.0
	var speeds = 0.0
	var sub_herd_size = float(neighbours.size())
	var center_of_mass:Vector2
	
	
	if has_a_target():
		_target_position = get_target().position
	else :
		if sub_herd_size > 0.0 :
			for zombie in neighbours:
				xs += zombie.get_target_position().x
				ys += zombie.get_target_position().y
				speeds += zombie.current_speed			
			center_of_mass = Vector2 (xs / sub_herd_size, ys / sub_herd_size)
			_target_position = center_of_mass
#		else :
#			_target_position = position


func get_target_position() -> Vector2:
	return _target_position
	

func has_a_target() -> bool:
	return is_instance_valid(get_target())


func set_target(target:Node2D) -> void:
	_target = target


func get_target() -> Node2D :
	return _target


func set_id(id:int) -> void:
	_id = id
	$IdLabel.text = str(_id)


func get_id() -> int:
	return _id


func is_roaming() -> bool :
	return _roaming


func set_roaming(value:bool) :
	_roaming = value


func _on_SightRange_body_entered(body):
	if body.is_in_group("prey") :
		Log.debug("Zombie #" + str(get_id()) + " _show_aggro_range the signal", "_on_SightRange_body_entered")
		emit_signal("prey_detected", self, body)
	
	if body != self and body.is_in_group("zombie"):
		neighbours.append(body)


func _on_SightRange_body_exited(body):
	if body != self and body.is_in_group("zombie"):
		var index = neighbours.find(body)
		if index > -1 :
			neighbours.remove(index)


func consider_targetting(prey) -> void :
	var prey_to_target = prey	
	if has_a_target():
		Log.debug("Zombie #" + str(get_id()) + " already have a target", "consider_targetting")
		prey_to_target = _get_closest_prey(get_target(), prey)
	else :
		Log.debug("Zombie #" + str(get_id()) + " starts targetting this prey", "consider_targetting")		
	set_target(prey_to_target)	
	update()


func _get_closest_prey(prey1, prey2) -> Node2D :
	var distance1 = position.distance_to(prey1.position)
	var distance2 = position.distance_to(prey2.position)
	if distance1 < distance2 :
		Log.debug("Actual prey is closest. Zombie #" + str(get_id()) + " keeps on targetting it", "_get_closest_prey")
		return prey1
	else :
		Log.debug("New prey is closest. Zombie #" + str(get_id()) + " changes target", "_get_closest_prey")
		return prey2


func roam() -> void:
	current_speed = rng.randf_range(max_speed / 2.0, max_speed)
	var random_position = (Vector2 (rng.randf_range(0.0, get_viewport().size.x), rng.randf_range(0.0, get_viewport().size.y)) - position) * current_speed
	rotate(get_angle_to(random_position))
	set_roaming(true)


func show_aggro_range() -> void :
	_show_aggro_range = true
	yield(get_tree().create_timer(2.0), "timeout")
	_show_aggro_range = false



func _draw():
	if _show_aggro_range :
		draw_arc(to_local(position), aggro_range, deg2rad(0.0), deg2rad(360.0), 50, Color.aquamarine, 1.0)	
	if has_a_target():
		draw_line(to_local(position), to_local(get_target().position), Color.yellow)
	else :
		draw_line(to_local(position), to_local(get_target_position()), Color.red)

func _on_Mouth_body_entered(body):
	if body.is_in_group("human") :
		body.turn_into_zombie()
		set_target(null)
#		roam()
