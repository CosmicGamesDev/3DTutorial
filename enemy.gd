extends CharacterBody3D


const SPEED = 200.0
var target_player = null
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	target_player = get_tree().get_nodes_in_group("player")[0]

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	look_at(target_player.global_position,Vector3.UP)
	var direction_to_player = (target_player.global_position - global_position).normalized()
	velocity.z = direction_to_player.z * SPEED * delta
	velocity.x = direction_to_player.x * SPEED * delta
	$AnimationPlayer.play("Running_A")
	move_and_slide()


func _on_hurtbox_area_entered(area):
	queue_free()
