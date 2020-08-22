extends KinematicBody2D

var direction := Vector2(1, -1).normalized()
var started: bool
var speed := 800

var destruction := 1
var hits := 0
var explosion := 0

signal hit
signal hit2

func _physics_process(delta: float) -> void:
	if not started:
		return
	
	var col := move_and_collide(direction * speed * delta)
	if col:
		if col.collider.is_in_group("building"):
			emit_signal("hit")
			col.collider.destroy()
			
			hits += 1
			if hits == destruction:
				hits = 0
				direction = direction.bounce(col.normal)
			else:
				position += col.remainder
		elif col.collider.name == "Paddle":
			direction = direction.bounce(col.normal)
			emit_signal("hit2")
			direction = get_parent().up().rotated(position.distance_to(get_parent().paddle.position) * sign(position.x - get_parent().paddle.position.x) / 320 * PI/4)
		else:
			direction = direction.bounce(col.normal)
			emit_signal("hit2")
