## ECS Demo - Mobile-first with 3D GridMap + 2D Cards
extends Control

## Reference to ECS world
var ecs_world: World = null

## 3D Scene references
@onready var world_3d: Node3D = $VBoxContainer/TopView3D/SubViewport/World3D
@onready var camera_3d: Camera3D = $VBoxContainer/TopView3D/SubViewport/World3D/Camera3D
@onready var grid_map: GridMap = $VBoxContainer/TopView3D/SubViewport/World3D/GridMap

## 2D UI references
@onready var cards_container: HBoxContainer = $VBoxContainer/BottomView2D/MarginContainer/VBoxContainer/CardsContainer
@onready var effects_label: Label = $VBoxContainer/BottomView2D/MarginContainer/VBoxContainer/EffectsLabel


func _ready() -> void:
	# Create the ECS world
	ecs_world = World.new()
	world_3d.add_child(ecs_world)
	
	# Add systems to the world
	ecs_world.add_system(RenderSystem.new())
	ecs_world.add_system(DeathSystem.new())
	
	# Setup 3D view
	_setup_3d_world()
	
	# Setup 2D cards UI
	_setup_cards_ui()
	
	# Create some example entities
	_create_entities_3d()
	
	# Demo: Create entity that will die
	_create_dying_entity()


func _process(delta: float) -> void:
	# Update ECS world every frame
	ecs_world.update(delta)
	
	# Update health labels
	_update_health_labels()


func _setup_3d_world() -> void:
	## Setup the 3D GridMap world
	# GridMap will be configured for tile-based entities
	pass


func _setup_cards_ui() -> void:
	## Setup the cards and effects UI
	# Create example card buttons in horizontal row at bottom (portrait mode)
	for i in range(3):
		var card_button = Button.new()
		card_button.text = "Card\n%d" % (i + 1)
		card_button.custom_minimum_size = Vector2(90, 110)
		card_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card_button.pressed.connect(_on_card_pressed.bind(i + 1))
		cards_container.add_child(card_button)


func _create_entities_3d() -> void:
	## Create entities that will appear in the 3D GridMap
	## Example 1: Entity at grid position
	var entity1 = ecs_world.create_entity()
	entity1.add_component(PositionComponent.new(Vector3(-1, 0.5, 0)))  # Grid coordinates (x, y, z)
	entity1.add_component(HealthComponent.new(100))
	
	## Example 2: Another entity
	var entity2 = ecs_world.create_entity()
	entity2.add_component(PositionComponent.new(Vector3(1, 0.5, 1)))  # Grid coordinates (x, y, z)
	entity2.add_component(HealthComponent.new(100))
	
	## Example 3: Entity at different position
	var entity3 = ecs_world.create_entity()
	entity3.add_component(PositionComponent.new(Vector3(-1, 0.5, 1)))  # Grid coordinates (x, y, z)
	entity3.add_component(HealthComponent.new(50))
	
	# Create 3D representations in GridMap
	_spawn_entities_in_grid()


func _spawn_entities_in_grid() -> void:
	## Spawn 3D mesh instances in GridMap for each entity with health display
	var entities = ecs_world.query([PositionComponent])
	for entity in entities:
		var pos = entity.get_component(PositionComponent) as PositionComponent
		var health = entity.get_component(HealthComponent) as HealthComponent
		
		# Create a simple 3D visual representation
		var mesh_instance = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = Vector3(0.8, 0.8, 0.8)
		mesh_instance.mesh = box_mesh
		mesh_instance.position = pos.position
		world_3d.add_child(mesh_instance)
		
		# Add health display label above the entity
		if health:
			var label_3d = Label3D.new()
			label_3d.text = "%d/%d" % [health.current, health.maximum]
			label_3d.position = pos.position + Vector3(0, 1.2, 0)  # Above the entity
			label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			label_3d.font_size = 32
			label_3d.outline_size = 4
			label_3d.modulate = Color.WHITE
			world_3d.add_child(label_3d)
			
			# Store reference for updating
			entity.set_meta("health_label", label_3d)


func _create_dying_entity() -> void:
	## Create entity that will die in 3 seconds
	var dying_entity = ecs_world.create_entity()
	dying_entity.add_component(PositionComponent.new(Vector3(6, 0.5, 3)))
	dying_entity.add_component(HealthComponent.new(100))
	
	# Kill it after 3 seconds
	await get_tree().create_timer(3.0).timeout
	var health = dying_entity.get_component(HealthComponent) as HealthComponent
	if health:
		health.take_damage(100)
		_show_effect("Entity destroyed!")
		print("Dealt 100 damage to entity %d" % dying_entity.entity_id)


func _on_card_pressed(card_id: int) -> void:
	## Handle card button press
	_show_effect("Card %d played!" % card_id)
	print("Card %d activated" % card_id)
	
	# Example: Damage random entity
	var entities = ecs_world.query([HealthComponent])
	if entities.size() > 0:
		var random_entity = entities[randi() % entities.size()]
		var health = random_entity.get_component(HealthComponent) as HealthComponent
		health.take_damage(10)
		print("Dealt 10 damage to entity %d (HP: %d/%d)" % [
			random_entity.entity_id, 
			health.current, 
			health.maximum
		])


func _update_health_labels() -> void:
	## Update health labels for all entities
	var entities = ecs_world.query([HealthComponent])
	for entity in entities:
		if entity.has_meta("health_label"):
			var health = entity.get_component(HealthComponent) as HealthComponent
			var label = entity.get_meta("health_label") as Label3D
			if label and health:
				label.text = "%d/%d" % [health.current, health.maximum]
				# Change color based on health percentage
				var health_percent = float(health.current) / float(health.maximum)
				if health_percent > 0.6:
					label.modulate = Color.GREEN
				elif health_percent > 0.3:
					label.modulate = Color.YELLOW
				else:
					label.modulate = Color.RED


func _show_effect(message: String) -> void:
	## Show effect message in the bottom panel UI
	effects_label.text = message
	# Auto-clear after 2 seconds
	await get_tree().create_timer(2.0).timeout
	if effects_label.text == message:  # Only clear if not replaced
		effects_label.text = "Tap a card to play"


## Demo: Manually query entities
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):  # Space bar
		print("\n=== ECS Query Demo ===")
		
		# Query all entities with health
		var entities_with_health = ecs_world.query([HealthComponent])
		print("Entities with health: %d" % entities_with_health.size())
		var status_text = "Entities: %d\n" % entities_with_health.size()
		
		for entity in entities_with_health:
			var health = entity.get_component(HealthComponent) as HealthComponent
			var pos = entity.get_component(PositionComponent) as PositionComponent
			print("  Entity %d: HP = %d/%d at %s" % [
				entity.entity_id, 
				health.current, 
				health.maximum,
				pos.position if pos else "N/A"
			])
			status_text += "E%d: HP %d/%d " % [entity.entity_id, health.current, health.maximum]
		
		_show_effect(status_text.strip_edges())
