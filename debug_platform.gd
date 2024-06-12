@tool
extends StaticBody2D

## Pickable needs to be selected from the inspector [br]
## this show a warn about it
@export var is_debug := true

@export var is_rotate := false
@export_range(0.0, 360.0) var rot_start_degrees := 0.0
@export var is_door := false
@export var door_length := 100.0
@export_node_path("Marker2D") var door_start_pos_mark_np : NodePath
@export var speed := 50.0

@onready var coll_shape : CollisionShape2D = get_node('CollisionShape2D')

var can_grab := false
var grabbed_offset := Vector2()

var tween_door : Tween
var tween_rot : Tween

var door_mark : Marker2D


func _ready() -> void : 
	# scene/main/node.h:446 - Parameter "data.tree" is null.  wtf ???
	if is_debug and not input_pickable : 
		var warn_msg := "Debug_Pickable script is set in node {} and the input event is shoot. However, input_pickable is false. node path : {}. can turn off this warning set is_debug to false"
		warn_msg = warn_msg.format([self.name, self.get_path()],"{}")
		push_warning(warn_msg)
	
	if is_door : 
		door_mark = get_node(door_start_pos_mark_np)
#_ready


func _input_event(_viewport : Viewport, event : InputEvent, _shape_idx : int) -> void :
	if Engine.is_editor_hint() : 
		return
	
	if event is InputEventMouseButton : 
		can_grab = event.pressed
		grabbed_offset = position - get_global_mouse_position()
#_input_event


func _process(delta : float) -> void :
	if Engine.is_editor_hint() : 
		if is_door and not tween_door : 
			tween_door = create_tween()
			var tprop := tween_door.tween_property(self, "position:y", position.y + door_length, 1.0)
			await tprop.set_delay(1.0).finished
			tween_door = null
			global_position = door_mark.global_position
		
		if is_rotate and not tween_rot : 
			tween_rot = create_tween()
			var tprop := tween_rot.tween_property(self, "rotation", 360.0 , 1.0)
			await tprop.set_delay(1.0).finished
			tween_rot = null
			rotation = rot_start_degrees
		
		return
	#is_editor
	
	if is_rotate : 
		rotation_degrees += speed * delta # infinite
	
	if is_door : 
		position.y += speed * delta
		if global_position.y > door_mark.global_position.y + door_length : 
			is_door = false # lock the door
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_grab :
		position = get_global_mouse_position() + grabbed_offset
#_process
