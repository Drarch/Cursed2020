extends Node2D

onready var paddle := $Paddle as Node2D
onready var line := $PaddleLine as Line2D

var camera: Camera2D

func _ready() -> void:
	for i in 1000:
		$City.construct()
	$City/Timer.queue_free()
	$City.set_process(false)
	$City.set_process_input(false)
	
	camera = $City.camera
	
	var seq := TweenSequence.new()
	seq.append(camera, "global_position", paddle.get_node("CameraHere").global_position + Vector2(600, -600), 1)
	seq.parallel().append(camera, "rotation_degrees", 27, 1)
	seq.parallel().append(camera, "zoom", Vector2.ONE * 3, 1)

func _process(delta: float) -> void:
	paddle.global_position = line.to_global(line.get_local_mouse_position().project(line.points[1]))
