## ECS World - Manages entities and systems
class_name World
extends Node

## All entities - Dictionary[int, Entity]
var entities: Dictionary = {}

## All systems - Array[System]
var systems: Array[System] = []

## Next entity ID
var next_entity_id: int = 1


func _ready() -> void:
	# Sort systems by priority
	systems.sort_custom(func(a, b): return a.priority < b.priority)


## Main update loop - call in _process or _physics_process
func update(delta: float) -> void:
	for system in systems:
		system.process(delta)


## Create new entity
func create_entity() -> Entity:
	var entity = Entity.new(next_entity_id)
	entity.world = self
	entities[next_entity_id] = entity
	add_child(entity)
	next_entity_id += 1
	return entity


## Destroy entity
func destroy_entity(entity: Entity) -> void:
	if entity.entity_id in entities:
		# Remove from all system caches
		for system in systems:
			if entity in system.cached_entities:
				system.cached_entities.erase(entity)
				system.on_entity_removed(entity)
		
		# Remove from world
		entities.erase(entity.entity_id)
		entity.queue_free()


## Add system to world
func add_system(system: System) -> void:
	system.world = self
	systems.append(system)
	add_child(system)
	
	# Sort systems by priority
	systems.sort_custom(func(a, b): return a.priority < b.priority)
	
	# Build initial cache
	_rebuild_system_cache(system)


## Get all entities with specific components
func query(component_types: Array[Script]) -> Array[Entity]:
	var result: Array[Entity] = []
	for entity in entities.values():
		var has_all = true
		for comp_type in component_types:
			if not entity.has_component(comp_type):
				has_all = false
				break
		if has_all:
			result.append(entity)
	return result


## Internal: Called when component added to entity
func _on_component_added(entity: Entity, component: Component) -> void:
	# Update system caches
	for system in systems:
		if system.matches(entity) and entity not in system.cached_entities:
			system.cached_entities.append(entity)
			system.on_entity_added(entity)


## Internal: Called when component removed from entity
func _on_component_removed(entity: Entity, component: Component) -> void:
	# Update system caches
	for system in systems:
		if not system.matches(entity) and entity in system.cached_entities:
			system.cached_entities.erase(entity)
			system.on_entity_removed(entity)


## Internal: Rebuild cache for a system
func _rebuild_system_cache(system: System) -> void:
	system.cached_entities.clear()
	for entity in entities.values():
		if system.matches(entity):
			system.cached_entities.append(entity)
			system.on_entity_added(entity)

