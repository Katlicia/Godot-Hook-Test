class_name Player
extends CharacterBody3D

@export var speed = 15.0
@export var jump_force = 10.0
@export var gravity = 0.5

@export var acceleration = 10.0
@export var deceleration = 8.0

@export var sensitivity = 0.01

@onready var cam = $Camera3D
@onready var gc = $GrappleController


@onready var lefthookpos = $lefthook
@onready var righthookpos = $righthook

func _ready() -> void:
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
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		cam.rotate_x(-event.relative.y * sensitivity)
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		

#extends CharacterBody3D
#
#@onready var camera_mount = $"Camera Mount"
#@onready var visuals = $"Visuals"
#@onready var animation_player = $Visuals/MikasaGodot/AnimationPlayer
#
#@export var hook_scene: PackedScene  # Kanca sahnesi
#@onready var hook_launcher_l = $"Visuals/HookLauncherL"  # Sol elden fırlatma
#@onready var hook_launcher_r = $"Visuals/HookLauncherR"  # Sağ elden fırlatma
#@onready var line_left = $"Line2DLeft"  # Sol halat
#@onready var line_right = $"Line2DRight"  # Sağ halat
#
#var hook_instance_l: Node = null  # Sol kanca referansı
#var hook_instance_r: Node = null  # Sağ kanca referansı
#var pulling_to_hook: bool = false  # Oyuncu kancaya doğru çekiliyor mu?
#var hook_target_position: Vector3  # Kanca hedef pozisyonu
#
## Hareket hızları
#const WALKING_SPEED = 3.0
#const RUNNING_SPEED = 6.0
#const JUMP_VELOCITY = 4.5
#const GRAVITY = Vector3.DOWN * 9.8
#
## Duyarlılık ayarları
#@export var sens_horizontal = 0.5
#@export var sens_vertical = 0.5
#
## Değişkenler
#var running = false
#var is_locked = false
#
#func _ready():
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
#
#func _input(event):
	## Fare hareketi ile kamerayı döndürme
	#if event is InputEventMouseMotion:
		#rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		#camera_mount.rotate_x(deg_to_rad(-event.relative.y * sens_vertical))
		## Kamera sınırlaması
		#camera_mount.rotation_degrees.x = clamp(camera_mount.rotation_degrees.x, -45, 45)
#
	## Kanca fırlatma ve geri çekme
	#if event.is_action_pressed("fire_hook_left"):
		#fire_hook_left()
	#elif event.is_action_pressed("fire_hook_right"):
		#fire_hook_right()
	#elif event.is_action_pressed("retract_hook_left"):
		#retract_hook_left()
	#elif event.is_action_pressed("retract_hook_right"):
		#retract_hook_right()
#
#func _physics_process(delta: float) -> void:
	#if pulling_to_hook:
		#move_towards_hook(delta)
	#else:
		#normal_movement(delta)
#
#func _process(delta: float) -> void:
	#update_lines()
#
## Normal hareket
#func normal_movement(delta: float):
	## Animasyon oynuyorsa hareketi kilitle
	#if !animation_player.is_playing():
		#is_locked = false
#
	## Koşma kontrolü
	#running = Input.is_action_pressed("run")
	#var speed = RUNNING_SPEED if running else WALKING_SPEED
#
	## Yerçekimi uygulama
	#if not is_on_floor():
		#velocity += GRAVITY * delta
#
	## Zıplama
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		#animation_player.play("Jump")
#
	## Hareket yönü
	#var input_dir = Input.get_vector("left", "right", "forward", "back")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
#
	#if direction:
		#if !is_locked:
			## Koşma veya yürüme animasyonlarını tetikle
			#if running and animation_player.current_animation != "Run":
				#animation_player.play("Run")
			#elif not running and animation_player.current_animation != "Walk":
				#animation_player.play("Walk")
#
			## Görsellerin yönünü hareket yönüne çevir
			#visuals.look_at(position + direction)
		#velocity.x = direction.x * speed
		#velocity.z = direction.z * speed
	#else:
		## Hareket durunca yavaşlama
		#velocity.x = move_toward(velocity.x, 0, speed * delta)
		#velocity.z = move_toward(velocity.z, 0, speed * delta)
#
	## Karakteri hareket ettir
	#move_and_slide()
#
## Kanca hedefe çekilme
#func move_towards_hook(delta: float):
	## Oyuncuyu kanca pozisyonuna doğru çek
	#var direction = (hook_target_position - global_transform.origin).normalized()
	#velocity.x = direction.x * RUNNING_SPEED
	#velocity.y = direction.y * RUNNING_SPEED
	#velocity.z = direction.z * RUNNING_SPEED
#
	## Eğer kanca pozisyonuna yaklaştıysak çekilmeyi durdur
	#if global_transform.origin.distance_to(hook_target_position) < 1.0:
		#pulling_to_hook = false
		#velocity = Vector3.ZERO
	#else:
		#move_and_slide()
#
## Fare hedef pozisyonu
#func get_mouse_target_position() -> Vector3:
	#var camera = $"Camera Mount/Camera3D"
	#var from = camera.project_ray_origin(get_viewport().get_mouse_position())
	#var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
#
	#var space_state = get_world_3d().direct_space_state
	#var ray_query = PhysicsRayQueryParameters3D.new()
	#ray_query.from = from
	#ray_query.to = to
	#ray_query.collision_mask = 1
#
	#var result = space_state.intersect_ray(ray_query)
	#if result.has("position"):
		#return result["position"]
	#return from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 100
#
## Kanca fırlatma (sol)
#func fire_hook_left():
	#if hook_instance_l != null:
		#return  # Sol elde zaten bir kanca varsa yeni bir tane oluşturma
#
	#hook_instance_l = hook_scene.instantiate()
	#hook_instance_l.global_transform.origin = hook_launcher_l.global_transform.origin
	#hook_instance_l.target_position = get_mouse_target_position()
	#hook_instance_l.connect("hook_attached", Callable(self, "_on_hook_attached_left"))
	#get_parent().add_child(hook_instance_l)
#
## Kanca fırlatma (sağ)
#func fire_hook_right():
	#if hook_instance_r != null:
		#return  # Sağ elde zaten bir kanca varsa yeni bir tane oluşturma
#
	#hook_instance_r = hook_scene.instantiate()
	#hook_instance_r.global_transform.origin = hook_launcher_r.global_transform.origin
	#hook_instance_r.target_position = get_mouse_target_position()
	#hook_instance_r.connect("hook_attached", Callable(self, "_on_hook_attached_right"))
	#get_parent().add_child(hook_instance_r)
#
## Kanca geri çekme (sol)
#func retract_hook_left():
	#if hook_instance_l != null:
		#hook_instance_l.queue_free()
		#hook_instance_l = null
		#pulling_to_hook = false  # Çekilmeyi iptal et
#
## Kanca geri çekme (sağ)
#func retract_hook_right():
	#if hook_instance_r != null:
		#hook_instance_r.queue_free()
		#hook_instance_r = null
		#pulling_to_hook = false  # Çekilmeyi iptal et
#
## Halat güncelleme
#func update_lines():
	#if hook_instance_l != null:
		#line_left.points = [hook_launcher_l.global_transform.origin, hook_instance_l.global_transform.origin]
	#else:
		#line_left.points = []
#
	#if hook_instance_r != null:
		#line_right.points = [hook_launcher_r.global_transform.origin, hook_instance_r.global_transform.origin]
	#else:
		#line_right.points = []
#
## Kanca tutunduğunda (sol)
#func _on_hook_attached_left(body, position):
	#print("Sol kanca şu nesneye tutundu: ", body.name)
	#pulling_to_hook = true
	#hook_target_position = position
#
## Kanca tutunduğunda (sağ)
#func _on_hook_attached_right(body, position):
	#print("Sağ kanca şu nesneye tutundu: ", body.name)
	#pulling_to_hook = true
	#hook_target_position = position
