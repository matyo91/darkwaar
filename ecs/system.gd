## Base System Class
## All systems inherit from this and override process()
class_name System
extends Node

## Required component types for this system
## Override in subclasses: var required_components = [PositionComponent, SpriteComponent]
var required_components: Array[Script] = []

## Reference to world
var world: World = null

## Cache of entities that match this system
var cached_entities: Array[Entity] = []

## System priority (lower = runs first)
var priority: int = 0


func _init() -> void:
	pass


## Override this in subclasses
func process(delta: float) -> void:
	pass


## Check if entity matches this system's requirements
func matches(entity: Entity) -> bool:
	for component_type in required_components:
		if not entity.has_component(component_type):
			return false
	return true


## Called when entity is added to cached list
func on_entity_added(entity: Entity) -> void:
	pass


## Called when entity is removed from cached list
func on_entity_removed(entity: Entity) -> void:
	pass


## Helper: Get entities with specific components
func query(component_types: Array[Script]) -> Array[Entity]:
	var result: Array[Entity] = []
	for entity in world.entities.values():
		var has_all = true
		for comp_type in component_types:
			if not entity.has_component(comp_type):
				has_all = false
				break
		if has_all:
			result.append(entity)
	return result
