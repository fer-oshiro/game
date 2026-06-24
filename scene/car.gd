extends Area2D

@export var direction := Vector2.RIGHT
@export var speed = 2
var colors = [
	preload("res://graphics/cars/green.png"), 
	preload("res://graphics/cars/red.png"), 
	preload("res://graphics/cars/yellow.png")
	]

func _ready() -> void:
	$Sprite2D.texture = colors.pick_random()
	$Sprite2D.flip_h = position.x < 100
	if position.x > 100:
		direction = Vector2.LEFT
		

func _process(delta: float) -> void:
	position += direction * speed * (delta * 80)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.
