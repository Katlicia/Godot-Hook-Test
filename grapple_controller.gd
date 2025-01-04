extends Node

@export var left_ray: RayCast3D
@export var right_ray: RayCast3D
@export var rope_scene: PackedScene

@export var rest_length = 2.0
@export var stiffness = 10.0
@export var damping = 1.0

@onready var player: CharacterBody3D = get_parent()
@onready var lhookpos = player.get_node("lefthook")
@onready var rhookpos = player.get_node("righthook")


# Sol ve sağ kanca için ayrı değişkenler
var left_target: Vector3
var right_target: Vector3
var left_launched = false
var right_launched = false
var left_rope: Node3D
var right_rope: Node3D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_shoot"):
		launch_left()
	if Input.is_action_just_pressed("right_shoot"):
		launch_right()
	if Input.is_action_just_released("left_shoot"):
		retract_left()
	if Input.is_action_just_released("right_shoot"):
		retract_right()
	
	if left_launched:
		handle_grapple(delta, left_target, left_launched)
	if right_launched:
		handle_grapple(delta, right_target, right_launched)
	
	update_ropes()

func launch_left():
	if left_ray.is_colliding():
		left_target = left_ray.get_collision_point()
		left_launched = true
		if left_rope == null:
			left_rope = rope_scene.instantiate()
			add_child(left_rope)

func launch_right():
	if right_ray.is_colliding():
		right_target = right_ray.get_collision_point()
		right_launched = true
		if right_rope == null:
			right_rope = rope_scene.instantiate()
			add_child(right_rope)

func retract_left():
	left_launched = false
	if left_rope:
		left_rope.queue_free()
		left_rope = null

func retract_right():
	right_launched = false
	if right_rope:
		right_rope.queue_free()
		right_rope = null

func handle_grapple(delta: float, target: Vector3, launched: bool):
	if !launched:
		return

	var target_dir = player.global_position.direction_to(target)
	var target_dist = player.global_position.distance_to(target)
	var displacement = target_dist - rest_length
	
	if displacement > 0:
		var spring_force_magnitude = stiffness * displacement
		var spring_force = target_dir * spring_force_magnitude
		var vel_dot = player.velocity.dot(target_dir)
		var damping_force = -damping * vel_dot * target_dir
		var force = spring_force + damping_force
		player.velocity += force * delta

func update_ropes():
	update_rope(left_rope, left_target, left_launched, lhookpos.global_transform.origin)
	update_rope(right_rope, right_target, right_launched, rhookpos.global_transform.origin)

func update_rope(rope: Node3D, target: Vector3, launched: bool, start_pos: Vector3):
	if rope == null or !launched:
		if rope:
			rope.visible = false
		return

	rope.visible = true
	
	# Halatın oyuncudan hedefe doğru çizilmesi
	var end_position = target
	
	rope.global_transform.origin = start_pos  # Halatın başlangıç noktası
	rope.look_at(end_position)  # Hedefe doğru yönlendirme
	var dist = start_pos.distance_to(end_position)
	rope.scale = Vector3(1, 1, dist)  # Halat uzunluğunu ayarlama
