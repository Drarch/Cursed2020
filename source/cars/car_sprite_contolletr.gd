extends Sprite

var position_prev: Vector2
var velocity: Vector2

func _ready():
	position_prev = global_position

func _physics_process(delta):
	velocity = global_position - position_prev
	if velocity:
		var angle := velocity.angle()
		if angle <= 0:
			angle = abs(angle)
		else:
			angle = TAU - angle
		
		frame = int(round(angle / TAU * 8)) % 8
	
	position_prev = global_position
