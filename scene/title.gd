extends Control

func _ready() -> void:
	$Score.text = "High Score: " + str(Global.score)

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("space")):
		call_deferred("change_scene")

func change_scene():
	get_tree().change_scene_to_file("res://scene/game.tscn")
