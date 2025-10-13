## ECS Demo - Shows how to use the ECS system
extends Node2D

## Reference to ECS world
var ecs_world: World = null


func _ready() -> void:
	# Create the ECS world
	ecs_world = World.new()
	add_child(ecs_world)
	
	# Add systems to the world
	ecs_world.add_system(RenderSystem.new())
	ecs_world.add_system(DeathSystem.new())
	
	# Create some example entities
	_create_moving_entities()
	
	# Demo: Create entity that will die
	_create_dying_entity()


func _process(delta: float) -> void:
	# Update ECS world every frame
	ecs_world.update(delta)


func _create_moving_entities() -> void:
	## Example 1: Entity with sprite
	var entity1 = ecs_world.create_entity()
	entity1.add_component(PositionComponent.new(Vector2(100, 100)))
	entity1.add_component(SpriteComponent.new("res://icon.svg"))
	entity1.add_component(HealthComponent.new(100))
	
	## Example 2: Another entity
	var entity2 = ecs_world.create_entity()
	entity2.add_component(PositionComponent.new(Vector2(200, 200)))
	entity2.add_component(SpriteComponent.new("res://icon.svg"))
	entity2.add_component(HealthComponent.new(100))
	
	## Example 3: Entity with no sprite
	var entity3 = ecs_world.create_entity()
	entity3.add_component(PositionComponent.new(Vector2(300, 300)))
	entity3.add_component(HealthComponent.new(50))


func _create_dying_entity() -> void:
	## Create entity that will die in 3 seconds
	var dying_entity = ecs_world.create_entity()
	dying_entity.add_component(PositionComponent.new(Vector2(400, 100)))
	dying_entity.add_component(SpriteComponent.new("res://icon.svg"))
	dying_entity.add_component(HealthComponent.new(100))
	
	# Kill it after 3 seconds
	await get_tree().create_timer(3.0).timeout
	var health = dying_entity.get_component(HealthComponent) as HealthComponent
	if health:
		health.take_damage(100)
		print("Dealt 100 damage to entity %d" % dying_entity.entity_id)


## Demo: Manually query entities
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space bar
		print("\n=== ECS Query Demo ===")
		
		# Query all entities with health
		var entities_with_health = ecs_world.query([HealthComponent])
		print("Entities with health: %d" % entities_with_health.size())
		for entity in entities_with_health:
			var health = entity.get_component(HealthComponent) as HealthComponent
			print("  Entity %d: HP = %d/%d" % [entity.entity_id, health.current, health.maximum])
		
		# Query entities with position
		var positioned_entities = ecs_world.query([PositionComponent])
		print("\nPositioned entities: %d" % positioned_entities.size())
		for entity in positioned_entities:
			var pos = entity.get_component(PositionComponent) as PositionComponent
			print("  Entity %d: pos=%s" % [entity.entity_id, pos.position])
