extends CharacterBody2D

var direction := Vector2.ZERO
var speed := 3

func _ready():
	$AnimatedSprite2D.play("up")
	
func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	position += direction * speed
	animation()
	move_and_slide()
	return

func animation():
	direction = Input.get_vector("left", "right", "up", "down")

	if direction:
		if direction.x > 0:
			$AnimatedSprite2D.play("right")
		elif direction.x < 0:
			$AnimatedSprite2D.play("left")
		elif direction.y > 0:
			$AnimatedSprite2D.play("down")
		elif direction.y < 0:
			$AnimatedSprite2D.play("up")
	else:
		$AnimatedSprite2D.frame = 0
	
