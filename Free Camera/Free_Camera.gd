extends KinematicBody

export var sensitivity = 0.22
export var speed = 10
var velocity = Vector3()
var y_velocity = Vector3()
var view_rotation = Vector3()
# Called when the node enters the scene tree for the first time.
func _ready():
	print("player_ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Vector3()
	y_velocity.y = 0
	if Input.is_action_pressed("right"):
		direction += transform.basis.x
	elif Input.is_action_pressed("left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("down"):
		direction += transform.basis.z
	elif Input.is_action_pressed("up"):
		direction -= transform.basis.z
	
	var strafe_up = Input.is_action_pressed("jump")
	var strafe_down = Input.is_action_pressed("crouch")
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	direction.normalized()
	
	if strafe_up:
		velocity.y += speed * delta
	elif strafe_down:
		velocity.y += -speed * delta
	velocity = lerp(velocity,direction * speed,delta)
	move_and_slide(velocity)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		return
	rotation_degrees.y -= view_rotation.y
	$Camera.rotation_degrees.x -= view_rotation.x
	
	view_rotation = Vector3()
	
	move_and_slide(velocity+y_velocity * speed)
	direction = Vector3()
func _input(event):
	if event is InputEventMouseMotion:
		view_rotation.x = event.relative.y * sensitivity
		view_rotation.y = event.relative.x * sensitivity
