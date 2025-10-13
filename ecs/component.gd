## Base Component Class
## All components inherit from this
class_name Component
extends Resource

## Optional: Component-specific data
## Override in subclasses

func _init() -> void:
	pass

## Optional: Called when component is added to entity
func on_added(entity: Entity) -> void:
	pass

## Optional: Called when component is removed from entity
func on_removed(entity: Entity) -> void:
	pass
