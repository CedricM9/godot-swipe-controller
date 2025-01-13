extends Control

# This script will also work for a mouse if you go into Project->Project Setting->General->Input Devices->Pointing
# and enable the option for "Emulate Mouse from Touch"

# Input Variables
@export var swipe_threshold = 100
@export var tap_threshold = 12

# Angle to determine what the ratio between swipe.x and swipe.y is so that a swipe is a clear action.
# Example: if x=y then the swipe is diagonal and should be ignored. This would be an angle of 45
@export var swipe_angle = 55
var swipe_angle_multiplier = tan(deg_to_rad(swipe_angle))

# A deadzone is used to avoid accidental swipes for things like the navigation bar and notification drawer
@export var deadzone_percent_of_screen_height = 0.05 #Applies to top and bottom, so no swiping in 20% of the screen
@export var screen_resolution = Vector2(1080,1920) # Can be set here manually

# Movement Signals sent to the game scene
signal swipe(direction: Vector2)
signal tap(touch_position: Vector2)


# Handles all input events. When tapping a screen, an InputEventScreenTouch (Pressed) is fired, and when letting go,
# an InputEventScreenTouch (Released) is fired. If the player drags their finger before releasing, InputEventScreenDrag
# events are fired in specific intervals (Polling)
# Event Examples:
# InputEventScreenDrag: index=0, position=((669.7266, 2286.914)), relative=((-1.054688, -1.171875)), velocity=((0, 0)), pressure=1.00 ...
# InputEventScreenTouch: index=0, pressed=false, canceled=false, position=((877.2363, 871.875)), double_tap=false

var sequence_has_started = false
var registered_swipe = false
var start_pos

func _unhandled_input(event: Object) -> void:
	#print(event) # For debugging
	if event is InputEventScreenTouch:
		if event.pressed:  # Touch start
			sequence_has_started = true
			start_pos = event.get_position()
			#print("START: " + str(start_pos)) # For Debugging
		else:  # Touch release
			if sequence_has_started:
				var end_pos = event.get_position()
				var vector = end_pos - start_pos
				#print("TAP: " + str(vector)) # For Debugging
				if not registered_swipe and vector.length() < tap_threshold:
					tap.emit(start_pos)
				registered_swipe = false
				sequence_has_started = false
	elif event is InputEventScreenDrag:
		if sequence_has_started and not registered_swipe:
			var current_pos = event.get_position()
			var vector = current_pos - start_pos
			#print("DRAG: " + str(vector)) # For Debugging
			if vector.length() >= swipe_threshold and not point_in_deadzone(start_pos):
				registered_swipe = true
				evaluate_swipe(vector)


# Checks to see if a point on the screen is inside a given deadzone at the top or bottom of the screen
func point_in_deadzone(point: Vector2) -> bool:
	if point.y < (screen_resolution.y * deadzone_percent_of_screen_height):
		return true
	elif point.y > (screen_resolution.y - (screen_resolution.y * deadzone_percent_of_screen_height)):
		return true
	return false


# Receives a swipe vector that was already checked for length to be over the threshold.
# Determines what direction the swipe was and if it is determined to be dominantly in a single direction
func evaluate_swipe(direction: Vector2) -> bool:
	if abs(direction.x) > abs(direction.y) * swipe_angle_multiplier:
		#print("Horizontal Swipe") # For Debuggin
		swipe.emit(sign(direction.x) * Vector2(1,0))
		return true
	elif abs(direction.y) > abs(direction.x) * swipe_angle_multiplier:
		#print("Vertical Swipe") # For Debugging
		swipe.emit(sign(direction.y) * Vector2(0,-1))
		return true
	else:
		print("Swipe was not dominantly made in a single direction")
		return false
