extends KinematicBody2D

export(Vector2) var direction = Vector2(1, -1).normalized()
export var started: bool
export var speed := 800

export var destruction := 1
export var hits := 0
export var explosion := 0

signal hit(ball)
signal hit2(ball)

func _ready() -> void:
	connect("hit", get_parent(), "_on_Ball_hit")
	connect("hit2", get_parent(), "_on_Ball_hit2")

func _physics_process(delta: float) -> void:
	if not started:
		return
	
	var col := move_and_collide(direction * speed * delta)
	if col:
		if col.collider.is_in_group("building"):
			emit_signal("hit", self)
			col.collider.destroy()
			
			hits += 1
			if hits == destruction:
				hits = 0
				direction = direction.bounce(col.normal)
			else:
				position += col.remainder
		elif col.collider.name == "Paddle":
			direction = direction.bounce(col.normal)
			emit_signal("hit2", self)
			direction = get_parent().up().rotated(position.distance_to(get_parent().paddle.position) * sign(position.x - get_parent().paddle.position.x) / 320 * PI/4)
		else:
			direction = direction.bounce(col.normal)
			emit_signal("hit2", self)
