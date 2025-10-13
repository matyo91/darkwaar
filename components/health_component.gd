## Health Component - Holds health data
class_name HealthComponent
extends Component

var current: int = 100
var maximum: int = 100


func _init(hp: int = 100) -> void:
	current = hp
	maximum = hp


func take_damage(amount: int) -> void:
	current = max(0, current - amount)


func heal(amount: int) -> void:
	current = min(maximum, current + amount)


func is_alive() -> bool:
	return current > 0

