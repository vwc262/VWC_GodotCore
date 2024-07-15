extends Node3D

@export var pan_speed = 0.01
@export var zoom_speed = 0.01
@export var rotate_speed = 0.9

@export var can_pan: bool
@export var can_zoom: bool
@export var can_rotate: bool

var touch_points: Dictionary = {}
var start_distance
var start_zoom
var start_angle

var current_angle
var anclaDistancia : Vector2
var angle : float = 0

func _ready():
	ManejadorClicks.connect("Go_TO",MoverCamara)

func _input(event):
	if event is InputEventScreenTouch:
		handle_touch(event)
	elif event is InputEventScreenDrag:
		handle_drag(event)

func handle_touch(event: InputEventScreenTouch):
	if event.pressed:
		touch_points[event.index] = event.position
	else:
		touch_points.erase(event.index)

	if touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		start_distance = touch_point_positions[0].distance_to(touch_point_positions[1])
		start_zoom = position.y

		var current: Vector2 = touch_point_positions[1] - touch_point_positions[0]
		angle = anclaDistancia.normalized().dot(current.normalized())
		anclaDistancia = touch_point_positions[1] - touch_point_positions[0]

	elif touch_points.size() < 2:
		start_distance = 0
		angle = 0
		anclaDistancia = Vector2(0,0)

func handle_drag(event: InputEventScreenDrag):
	touch_points[event.index] = event.position		
	var parentTransform = get_global_transform()
	var forward: Vector3 = parentTransform.basis.z
	var right: Vector3 = parentTransform.basis.x

	if touch_points.size() == 1:
		if can_pan:
			var pan_vector = (forward + (event.relative.x * right ) + (event.relative.y * forward)) * pan_speed
			pan_vector.y = 0
			global_translate(pan_vector)

	elif touch_points.size() == 2:
		var touch_point_positions = touch_points.values()
		var current_dist = touch_point_positions[1].distance_to(touch_point_positions[0])
		
		var zoom_factor = current_dist / start_distance
		
		print()

		if can_rotate:
			var touch = touch_points.values()
			var delta : Vector2 = touch[1] - touch[0]
			if(abs(delta.angle_to(anclaDistancia) * 1000) > 3):
				rotate_camera(rotate_speed * sign(delta.angle_to(anclaDistancia)))
			anclaDistancia = delta;

		if can_zoom:
			position.y = start_zoom / zoom_factor
			limit_zoom()
			if(position.y <= 10):
				$Camera3D.rotation_degrees.x = lerp(-90,-20,inclinate_camera())
			else:
				$Camera3D.rotation_degrees.x = -90
				
func rotate_camera(currentangle: float):
	rotation_degrees.y += -currentangle

func limit_zoom():
	position.y = clamp(position.y, 5, 45)
	pass

func inclinate_camera():		
	return remap(position.y, 10, 5, 0, 1)

func crearMiTween(callBack) -> Tween:
	var tween = create_tween()
	tween.connect("finished",callBack)
	return tween
	
func MovimientoRealizado():
	print('Tween terminado');
	pass	

func MoverCamara(positionToGo):
	print('quiere ir a ',positionToGo )
	var tween := crearMiTween(MovimientoRealizado)
	tween.tween_property(self,"position",positionToGo,1.5)	
