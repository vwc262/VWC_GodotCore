extends CSGBox3D

signal IrA
			
func _on_area_3d_2_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_mask == MOUSE_BUTTON_LEFT:					
		ManejadorClicks.emit_signal("Go_TO",position)
