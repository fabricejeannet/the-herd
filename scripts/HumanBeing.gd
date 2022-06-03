extends KinematicBody2D


var Zombie = preload("res://scenes/Zombie.tscn")

func turn_into_zombie() -> void :
		var zombie = Zombie.instance()
		zombie.position = self.position
		zombie.connect("prey_detected", get_parent(), "_on_prey_detected")
		get_parent().call_deferred("add_child", zombie)
		get_parent().herd.append(zombie)
		self.queue_free()
