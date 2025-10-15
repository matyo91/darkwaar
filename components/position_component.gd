## Position Component - Holds 3D position data
class_name PositionComponent
extends Component

var position: Vector3 = Vector3.ZERO


func _init(pos: Vector3 = Vector3.ZERO) -> void:
	position = pos
