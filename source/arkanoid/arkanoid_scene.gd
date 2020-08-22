extends Node2D

onready var paddle := $Paddle as Node2D
onready var ball := $Ball as KinematicBody2D
onready var line := $PaddleLine as Line2D
onready var particles := $Particles2D

var camera: Camera2D
var shake: int

func _ready() -> void:
	ball.hide()
	if not has_node("City"):
		add_child(load("res://CityView.tscn").instance())
		for i in 1000:
			$City.constructRandom()
	
	$City/Timer.queue_free()
	$City/AudioStreamPlayer.queue_free()
	$City.set_process(false)
	$City.set_process_input(false)
	
	camera = $City.camera
	
	var seq := TweenSequence.new()
	seq.append(camera, "global_position", paddle.get_node("CameraHere").global_position + Vector2(900, -800), 1)
	seq.parallel().append(camera, "rotation_degrees", 27, 1)
	seq.parallel().append(camera, "zoom", Vector2.ONE * 4, 1)
	seq.append_callback(self, "start")

func start():
	ball.position = paddle.position + up() * 50
	ball.started = true
	ball.show()

func _process(delta: float) -> void:
	paddle.global_position = line.to_global(line.get_local_mouse_position().project(line.points[1]))
	if shake:
		camera.offset = Vector2(rand_range(-shake, shake), rand_range(-shake, shake))
		shake -= 1
	else:
		camera.offset = Vector2()

func up() -> Vector2:
	return Vector2.UP.rotated(paddle.rotation)

func _on_Dead_body_entered(body: Node) -> void:
	ball.position = paddle.position + up() * 50

func _on_Ball_hit() -> void:
	var p = particles.duplicate() as Particles2D
	add_child(p)
	p.position = ball.position
	p.emitting = true
	get_tree().create_timer(1.5).connect("timeout", p, "queue_free")
	shake = 20
	
	var stream := AudioStreamPlayer.new()
	stream.stream = AudioStreamRandomPitch.new()
	stream.stream.audio_stream = load(str("res://arkanoid/impactPlate_heavy_00",randi() % 5 , ".wav"))
	stream.autoplay = true
	stream.volume_db = 5 + randi() % 6
	stream.connect("finished", stream, "queue_free")
	add_child(stream)
