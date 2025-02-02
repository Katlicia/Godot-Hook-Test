extends Node

@export var left_ray: RayCast3D
@export var right_ray: RayCast3D
@export var rope_scene: PackedScene
@export var grapple_speed = 15.0
@export var air_control = 5.0  # Havadaki hareket kontrolü gücü
@export var pull_const = 10.0


@onready var player: CharacterBody3D = get_parent()
@onready var lhookpos = player.get_node("lefthook")
@onready var rhookpos = player.get_node("righthook")

var left_target: Vector3
var right_target: Vector3
var left_launched = false
var right_launched = false
var left_rope: Node3D
var right_rope: Node3D
var gravity_multiplier = 1.0

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
		handle_grapple(delta, left_target)
	if right_launched:
		handle_grapple(delta, right_target)
	
	update_ropes()

func handle_grapple(delta: float, target: Vector3):
	var direction = (target - player.global_transform.origin).normalized()
	var desired_velocity = direction * grapple_speed
	player.velocity = lerp(player.velocity, desired_velocity , 0.1)
	 
	#var direction = (target - player.global_transform.origin).normalized()
	#var distance = (target - player.global_transform.origin).length()
	#var move_amount = min(distance , grapple_speed * delta)
	#player.global_transform.origin += direction * move_amount
	
	var dir_to_target = player.global_position.direction_to(target)
	
	# Yerçekimini azalt
	gravity_multiplier = 0.3
	
	# Ana çekiş kuvveti
	var pull_force = dir_to_target * grapple_speed
	player.velocity += pull_force * delta * pull_const
	# Havada hareket kontrolü
	var move_input = Vector3.ZERO
	if Input.is_action_pressed("right"):
		move_input.x += 1
	if Input.is_action_pressed("left"):
		move_input.x -= 1
	if Input.is_action_pressed("forward"):
		move_input.z -= 1
	if Input.is_action_pressed("back"):
		move_input.z += 1
	
	if move_input != Vector3.ZERO:
		move_input = move_input.normalized()
		var camera = get_viewport().get_camera_3d()
		var camera_basis = camera.global_transform.basis
		var movement = camera_basis * Vector3(move_input.x, 0, move_input.z)
		movement = movement.normalized() * air_control
		
		# Hareket yönünde ek kuvvet uygula
		player.velocity += movement * delta * 20.0
	
	# Hız sınırlaması
	var max_speed = 50.0
	if player.velocity.length() > max_speed:
		player.velocity = player.velocity.normalized() * max_speed

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
	gravity_multiplier = 1.0
	# Momentum boost
	player.velocity += player.velocity.normalized() * 10.0

func retract_right():
	right_launched = false
	if right_rope:
		right_rope.queue_free()
		right_rope = null
	gravity_multiplier = 1.0
	# Momentum boost
	player.velocity += player.velocity.normalized() * 10.0

func update_ropes():
	update_rope(left_rope, left_target, left_launched, lhookpos.global_transform.origin)
	update_rope(right_rope, right_target, right_launched, rhookpos.global_transform.origin)

func update_rope(rope: Node3D, target: Vector3, launched: bool, start_pos: Vector3):
	if rope == null or !launched:
		if rope:
			rope.visible = false
		return

	rope.visible = true
	rope.global_transform.origin = start_pos
	rope.look_at(target)
	var dist = start_pos.distance_to(target)
	rope.scale = Vector3(1, 1, dist)
