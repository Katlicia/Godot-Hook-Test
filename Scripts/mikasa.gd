extends CharacterBody3D
@onready var camera_mount = $"Camera Mount"
@onready var visuals = $"Visuals"
@onready var animation_player = $Visuals/MikasaGodot/AnimationPlayer
@onready var gc = $GrappleController

# Hareket hızları
@export var speed = 15.0
@export var jump_force = 10.0
@export var gravity = 0.5

@export var acceleration = 10.0
@export var deceleration = 8.0

# Duyarlılık ayarları
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

# Değişkenler
var running = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var move_vec = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if input_dir.length() != 0:
		velocity.x = lerpf(velocity.x, move_vec.x * speed, acceleration * delta)
		velocity.z = lerpf(velocity.z, move_vec.z * speed, acceleration * delta)
	else:
		velocity.x = lerpf(velocity.x, 0.0, deceleration * delta)
		velocity.z = lerpf(velocity.z, 0.0, deceleration * delta)
	
	# Jumping / Gravity
	if !is_on_floor():
		velocity.y -= gravity
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y += jump_force
	

	if Input.is_action_pressed("shift"):
		speed = 25.0
	if Input.is_action_just_released("shift"):
		speed = 15.0
		
	move_and_slide()

func _input(event):
	# Fare hareketi ile kamerayı döndürme
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		# Kamera sınırlaması
		camera_mount.rotation_degrees.x = clamp(camera_mount.rotation_degrees.x, -45, 45)


# Fare hedef pozisyonu
func get_mouse_target_position() -> Vector3:
	var camera = $"Camera Mount/Camera3D"
	var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000

	var space_state = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collision_mask = 1

	var result = space_state.intersect_ray(ray_query)
	if result.has("position"):
		return result["position"]
	return from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 100
