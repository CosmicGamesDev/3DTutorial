extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 9
@onready var fireball_scene = preload("res://fireball.tscn")
@onready var history_marker_scene = preload("res://history_marker.tscn")
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var animation_timer = $Timer as Timer
@onready var position_tracker_timer = $PositionTrackerTimer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var blink_animation = $BlinkAnimation
var position_tracker = []

func _ready():
	animation_timer.timeout.connect(_jump_start_animation_end)
	$TeleportRing.visible = false

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and animation_timer.is_stopped():
		animation_player.play("Jump_Start")
		animation_timer.start()
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_axis("ui_down","ui_up")
	var rotate_dir = Input.get_axis("ui_left","ui_right")
	var direction = (transform.basis * Vector3(0, 0, input_dir)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	if direction and animation_timer.is_stopped():
		animation_player.play("Running_A")
	if velocity.y != 0:
		animation_player.play("Jump_Idle")
	if velocity == Vector3.ZERO and animation_timer.is_stopped():
		animation_player.play("Idle")
	if rotate_dir:
		rotate_y(.1 * rotate_dir)
	blink()
	recall()
	attack()
	move_and_slide()

func _jump_start_animation_end():
	pass

func blink():
	if Input.is_action_just_pressed("blink"):
		velocity.x = velocity.x * 80
		velocity.z = velocity.z * 80
		animation_player.play("Dodge_Forward")
		blink_animation.play("blink")
		animation_timer.start()
		animation_timer.wait_time = animation_player.current_animation_length
		

func attack():
	if Input.is_action_just_pressed("attack"):
		var fireball = fireball_scene.instantiate()
		get_tree().root.add_child(fireball)
		fireball.global_position = $FireballPosition.global_position
		fireball.rotation = rotation
		fireball.direction = (transform.basis * Vector3(0, 0, 1)).normalized()
		animation_player.play("1H_Ranged_Shoot")
		animation_timer.start()
		animation_timer.wait_time = animation_player.current_animation_length

func recall():
	if Input.is_action_just_pressed("recall"):
		var tween = create_tween()
		for pos in position_tracker:
			tween.tween_property(self, "global_position", pos.global_position, .1)
		

func _on_position_tracker_timer_timeout():
	var history_marker = history_marker_scene.instantiate()
	get_tree().root.add_child(history_marker)
	history_marker.global_position = global_position
	position_tracker.push_front(history_marker)
	if position_tracker.size() > 20:
		position_tracker.pop_back().queue_free()
