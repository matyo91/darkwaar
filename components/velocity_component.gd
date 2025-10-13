## Velocity Component - Holds velocity data
class_name VelocityComponent
extends Component

var velocity: Vector2 = Vector2.ZERO


func _init(vel: Vector2 = Vector2.ZERO) -> void:
	velocity = vel
