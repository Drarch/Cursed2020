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

func set_car_type( id ):
	var idx = 0
	match id:
		0:
			idx = randi()%Globals.car_civil.size()
			texture = Globals.car_civil[idx]
			get_parent().movementspeed = (16.0 + idx ) * rand_range(0.90,1.10)
			get_parent().friction = 0.93 + rand_range(-0.005,0.005)
		1:
			idx = randi()%Globals.car_cargo.size()
			texture = Globals.car_cargo[idx]
			get_parent().movementspeed = (18.0 + idx ) * rand_range(0.90,1.10)
			get_parent().friction = 0.92 + rand_range(-0.005,0.005)
		2:
			idx = randi()%Globals.car_lumber.size()
			texture = Globals.car_lumber[idx]
			get_parent().movementspeed = (8.0 + idx ) * rand_range(0.90,1.10)
			get_parent().friction = 0.95 + rand_range(-0.005,0.005)
		3:
			idx = randi()%Globals.car_builder.size()
			texture = Globals.car_builder[idx]
			get_parent().movementspeed = (26.0 + idx ) * rand_range(0.90,1.10)
			get_parent().friction = 0.90 + rand_range(-0.005,0.005)

