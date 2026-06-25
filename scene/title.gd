extends Control

func _ready() -> void:
	$Score.text = "High Score: " + str(Global.score)
	var speech_node = get_node("/root/Global")
	speech_node.texto_reconhecido.connect(atualizar_texto)

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("space")):
		call_deferred("change_scene")

func change_scene():
	get_tree().change_scene_to_file("res://scene/game.tscn")


func _on_menu_button_pressed() -> void:
	Global.start_listening()
	pass # Replace with function body.


func _on_menu_button_2_pressed() -> void:
	Global.stop_listening()
	pass # Replace with function body.

func atualizar_texto(text):
	$Label2.text = text
