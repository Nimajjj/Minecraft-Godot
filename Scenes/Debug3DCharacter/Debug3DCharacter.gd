extends KinematicBody

var world

var speed = 20
const ACCEL_DEFAULT = 14
const ACCEL_AIR = 1
onready var accel = ACCEL_DEFAULT

var cam_accel = 40
var mouse_sense = 0.1

var direction = Vector3()
var velocity = Vector3()

onready var head = $Head
onready var camera = $Head/Camera
onready var raycast = $Head/RayCast

func _ready():
	#hides the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event):
	#get mouse input for camera rotation
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sense))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sense))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-89), deg2rad(89))
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.is_action_just_pressed("lmb"):
		_place_voxel(null)
	if Input.is_action_just_pressed("rmb"):
		_place_voxel(-1)


func _process(delta):
	#camera physics interpolation to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.iterations_per_second:
		camera.set_as_toplevel(true)
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(head.global_transform.origin, cam_accel * delta)
		camera.rotation.y = rotation.y
		camera.rotation.x = head.rotation.x
	else:
		camera.set_as_toplevel(false)
		camera.global_transform = head.global_transform
		
		
func _physics_process(delta):
	#get keyboard input
	direction = Vector3.ZERO
	var h_rot = global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var up_input = Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
	direction = Vector3(h_input, up_input, f_input).rotated(Vector3.UP, h_rot).normalized()
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, accel * delta)
	var __ = move_and_slide(velocity, Vector3.UP)
	

func _place_voxel(voxel):
	if raycast.is_colliding():
		var collision_pos = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		if voxel == null:
			world.set_voxel_at(collision_pos - (collision_normal/2), voxel)
			return
		world.set_voxel_at(collision_pos + (collision_normal/2), voxel)
		
		
		
