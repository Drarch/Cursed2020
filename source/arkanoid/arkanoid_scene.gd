extends Node2D

##todo wynik

const POWER_UP_NOCHANCE = 10

onready var paddle := $Paddle as Node2D
onready var ball := $Ball as KinematicBody2D
onready var line := $PaddleLine as Line2D
onready var particles := $Particles2D
onready var label := $CanvasLayer/Label
onready var ap := $CanvasLayer/AnimationPlayer as AnimationPlayer

onready var mushrooms_node := $CanvasLayer/ColorRect

var camera: Camera2D
var shake: int
var tilemap: TileMap
var city

var mushrooms: float

func _ready() -> void:
	ball.hide()
	label.hide()
	
	if not has_node("City"):
		add_child(load("res://CityView.tscn").instance())
		for i in 1000:
			$City.constructRandom()
	
	$City/Timer.queue_free()
	$City/AudioStreamPlayer.queue_free()
	$City.set_process(false)
	$City.set_process_input(false)
	
	camera = $City.camera
	tilemap = $City/Navigation2D/TileMap
	city = $City
	
	var seq := TweenSequence.new()
	seq.append(camera, "global_position", paddle.get_node("CameraHere").global_position + Vector2(900, -800), 1)
	seq.parallel().append(camera, "rotation_degrees", 27, 1)
	seq.parallel().append(camera, "zoom", Vector2.ONE * 4, 1)
	seq.append_callback(self, "start")

func start():
	get_tree().set_auto_accept_quit(true)
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
	
	mushrooms -= delta
	mushrooms_node.visible = mushrooms > 0

func up() -> Vector2:
	return Vector2.UP.rotated(paddle.rotation)

func _on_Dead_body_entered(body: Node) -> void:
	ball.position = paddle.position + up() * 50
	if ball.started:
		play_sample("res://arkanoid/call_for_backup.wav")

func _on_Ball_hit() -> void:
	partcl(ball.global_position)
	shake = 20 + ball.explosion
	
	var pos = tilemap.world_to_map(ball.global_position - tilemap.global_position)
	for i in ball.explosion:
		var radius = ceil(ball.explosion * 0.1) as int
		var cell = pos + Vector2(-radius + randi() % (radius * 2 + 1), -radius + randi() % (radius * 2 + 1))
		if cell in city.buildings_data:
			if city.buildings_data[cell]:
				partcl(city.buildings_data[cell].global_position)
				city.buildings_data[cell].destroy()
	
	if randi() % POWER_UP_NOCHANCE == 0:
		var powerup := preload("res://arkanoid/powerup.tscn").instance()
		powerup.position = ball.position
		powerup.up = -up()
		powerup.connect("powerup", self, "powerup")
		add_child(powerup)
	
	var stream = play_sample(str("res://arkanoid/impactPlate_heavy_00",randi() % 5 , ".wav"))
	stream.volume_db = 5 + ball.explosion * 0.1 + randi() % 6

func partcl(pp: Vector2):
	var p = particles.duplicate() as Particles2D
	add_child(p)
	p.global_position = pp
	p.emitting = true
	get_tree().create_timer(1.5).connect("timeout", p, "queue_free")

func _on_Ball_hit2() -> void:
	var stream = play_sample(str("res://arkanoid/impactMetal_heavy_00",randi() % 5 , ".wav"))
	stream.volume_db = 5 + randi() % 6

func play_sample(sample):
	var stream := AudioStreamPlayer.new()
	stream.stream = AudioStreamRandomPitch.new()
	stream.stream.audio_stream = load(sample)
	stream.autoplay = true
	stream.connect("finished", stream, "queue_free")
	add_child(stream)
	return stream

func powerup(id):
	play_sample("res://arkanoid/level_up.wav")
#	id = 4
	
	match id:
		0:
			ball.speed += 1
			label.text = "SPEED UP"
		1:
			ball.destruction += 1
			label.text = "DESTRUCTION UP"
		2:
			ball.explosion += 1
			label.text = "EXPLOSION UP"
		3:
			for cell in city.buildings_data:
				if city.buildings_data[cell]:
					city.buildings_data[cell].increase()
			label.text = "CITY UP"
		4:
			label.text = "MUSHROOM UP"
			mushrooms = max(mushrooms + 5, 5)
		5:
			label.text = "CREEPS UP"##TODO
		6:
			ball.speed += 2000
			label.text = "HYPER UP"
			get_tree().create_timer(5).connect("timeout", self, "dehyper")
		7:
			paddle.scale.x = 10
			label.text = "PADDLE UP"
			get_tree().create_timer(5).connect("timeout", self, "depaddle")
		8:
			$AudioStreamPlayer.pitch_scale += 0.1
			label.text = "MUSIC UP"

	ap.play("POWERUP")

func dehyper():
	ball.speed -= 2000

func depaddle():
	paddle.scale.x = 1
