extends Sprite

var position_prev = Vector2.ZERO
var velocity = Vector2.ZERO
var divider = TAU / 4

func _ready():
	position_prev = global_position

func _physics_process(delta):
	velocity = global_position - position_prev
	if velocity :
		position_prev = global_position
		var angle = Vector2.RIGHT.angle_to_point(velocity)
		var sprite_frame   = int(round( abs(angle) / (PI*0.25) )) % 8
#		angle = angle * divider 
#		print (angle, "-> ", floor(angle))
		$Label.text = str(angle) + "-> " + str(floor(angle))
		frame = sprite_frame
	
	
