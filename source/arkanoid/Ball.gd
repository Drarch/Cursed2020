extends KinematicBody2D

var direction := Vector2(1, -1).normalized()
var started: bool
var speed := 400

signal hit

func _physics_process(delta: float) -> void:
	if not started:
		return
	
	var col := move_and_collide(direction * speed * delta)
	if col:
		direction = direction.bounce(col.normal)
		if col.collider.is_in_group("building"):
			emit_signal("hit")
			speed += 10
			col.collider.destroy()
		elif col.collider.name == "Paddle":
			direction = get_parent().up().rotated(position.distance_to(get_parent().paddle.position) * sign(position.x - get_parent().paddle.position.x) / 320 * PI/4)
