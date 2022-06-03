extends "res://addons/gut/test.gd"
var Zombie = load("res://scripts/Zombie.gd")
var HumanBeing = load("res://scripts/HumanBeing.gd")

func test_can_create_a_zombie() -> void:
	var zombie = Zombie.new()	
	assert_not_null(zombie)


func test_zombie_doesnt_have_a_target_when_created() -> void:
	var zombie = Zombie.new()	
	assert_false(zombie.has_a_target())


#func test_zombie_can_dectect_a_prey() -> void:
#	var zombie = Zombie.new()	
#	var human_being = HumanBeing.new()
#	human_being.position = zombie.position + Vector2(150, 0)
#
	
