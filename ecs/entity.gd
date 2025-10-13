## Entity - A container for components
## In Godot ECS, entities are lightweight IDs with components
class_name Entity
extends Node

## Unique entity ID
var entity_id: int = 0

## Component storage - Dictionary[String, Component]
var components: Dictionary = {}

## Reference to the world
var world: World = null


func _init(id: int = 0) -> void:
	entity_id = id
	name = "Entity_%d" % id


## Add a component to this entity
func add_component(component: Component) -> Entity:
	var component_type = component.get_script().resource_path
	components[component_type] = component
	component.on_added(self)
	
	# Notify world that component was added
	if world:
		world._on_component_added(self, component)
	
	return self  # For chaining


## Get component by type (script path)
func get_component(component_type: Script) -> Component:
	var path = component_type.resource_path
	return components.get(path, null)


## Check if entity has component
func has_component(component_type: Script) -> bool:
	var path = component_type.resource_path
	return path in components


## Remove component
func remove_component(component_type: Script) -> void:
	var path = component_type.resource_path
	if path in components:
		var component = components[path]
		component.on_removed(self)
		components.erase(path)
		
		# Notify world
		if world:
			world._on_component_removed(self, component)


## Get all components
func get_all_components() -> Array:
	return components.values()


## Destroy entity
func destroy() -> void:
	if world:
		world.destroy_entity(self)
