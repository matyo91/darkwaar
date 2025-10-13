# ECS Cheat Sheet

## Quick Setup (Copy-Paste Ready)

### Create World
```gdscript
extends Node2D

var ecs_world: World = null

func _ready():
	ecs_world = World.new()
	add_child(ecs_world)
	ecs_world.add_system(RenderSystem.new())
	ecs_world.add_system(DeathSystem.new())

func _process(delta):
	ecs_world.update(delta)
```

### Create Entity
```gdscript
var entity = ecs_world.create_entity()
entity.add_component(PositionComponent.new(Vector2(100, 100)))
entity.add_component(SpriteComponent.new("res://icon.svg"))
```

### Create Component
```gdscript
class_name MyComponent
extends Component

var my_value: int = 0

func _init(value: int = 0):
	my_value = value
```

### Create System
```gdscript
class_name MySystem
extends System

func _init():
	required_components = [MyComponent, PositionComponent]
	priority = 50

func process(delta: float):
	for entity in cached_entities:
		var my = entity.get_component(MyComponent)
		var pos = entity.get_component(PositionComponent)
		# Your logic here
```

## Common Operations

### Entity Operations
```gdscript
# Create
var e = ecs_world.create_entity()

# Add component (chainable)
e.add_component(PositionComponent.new())
 .add_component(SpriteComponent.new())

# Get component
var pos = e.get_component(PositionComponent) as PositionComponent

# Check component
if e.has_component(HealthComponent):
	print("Has health!")

# Remove component
e.remove_component(SpriteComponent)

# Destroy
e.destroy()
```

### Query Operations
```gdscript
# Query from world
var enemies = ecs_world.query([EnemyTag, HealthComponent])

# Query from system
var positioned = query([PositionComponent, SpriteComponent])

# Process results
for entity in enemies:
	var health = entity.get_component(HealthComponent)
	print(health.current)
```

### Component Lifecycle Hooks
```gdscript
class_name MyComponent
extends Component

func on_added(entity: Entity):
	print("Added to entity ", entity.entity_id)
	# Initialize here

func on_removed(entity: Entity):
	print("Removed from entity ", entity.entity_id)
	# Cleanup here
```

## Common Patterns

### Health/Damage
```gdscript
# Component
class_name HealthComponent
extends Component
var current: int
var maximum: int

func take_damage(amount: int):
	current = max(0, current - amount)

# System
for entity in cached_entities:
	var health = entity.get_component(HealthComponent)
	if health.current <= 0:
		entity.destroy()
```

### Sprite Rendering
```gdscript
# Component
class_name SpriteComponent
extends Component
var sprite: Sprite2D

func on_added(entity: Entity):
	sprite = Sprite2D.new()
	entity.add_child(sprite)
	sprite.texture = load("res://icon.svg")

# System
for entity in cached_entities:
	var pos = entity.get_component(PositionComponent)
	var spr = entity.get_component(SpriteComponent)
	spr.sprite.position = pos.position
```

### Timer/Cooldown
```gdscript
class_name TimerComponent
extends Component
var time_left: float = 0.0
var duration: float = 1.0
var repeat: bool = false

# System
for entity in cached_entities:
	var timer = entity.get_component(TimerComponent)
	timer.time_left -= delta
	if timer.time_left <= 0:
		# Trigger event
		if timer.repeat:
			timer.time_left = timer.duration
		else:
			entity.remove_component(TimerComponent)
```

### Input Handling
```gdscript
class_name InputComponent
extends Component
var move_input: Vector2 = Vector2.ZERO

# System
func process(delta: float):
	for entity in cached_entities:
		var input = entity.get_component(InputComponent)
		var pos = entity.get_component(PositionComponent)
		
		input.move_input = Input.get_vector("left", "right", "up", "down")
		pos.position += input.move_input * 200.0 * delta
```

### AI/State Machine
```gdscript
class_name AIComponent
extends Component
enum State { IDLE, PATROL, CHASE, ATTACK }
var state: State = State.IDLE
var target: Entity = null

# System
func process(delta: float):
	for entity in cached_entities:
		var ai = entity.get_component(AIComponent)
		match ai.state:
			AIComponent.State.IDLE:
				_process_idle(entity, ai)
			AIComponent.State.PATROL:
				_process_patrol(entity, ai)
			AIComponent.State.CHASE:
				_process_chase(entity, ai)
```

### Tag-based Queries
```gdscript
# Tag components (no data, just markers)
class_name PlayerTag extends Component
class_name EnemyTag extends Component
class_name ItemTag extends Component

# Query by tag
var player = ecs_world.query([PlayerTag])[0]
var enemies = ecs_world.query([EnemyTag, HealthComponent])
var items = ecs_world.query([ItemTag, PositionComponent])
```

## System Priority Guide

```
Priority Guide (lower = runs first):
  0-50   : Input, AI decisions
  50-100 : Logic, Updates
  100-150: Rendering
  150-200: Effects
  200+   : Cleanup, Death
```

## Performance Tips

```gdscript
# ✅ GOOD: Use cached_entities
func process(delta: float):
	for entity in cached_entities:
		# Fast: iterates only matching entities

# ❌ BAD: Query every frame
func process(delta: float):
	var entities = world.query([MyComponent])  # Slow!
	for entity in entities:
		pass

# ✅ GOOD: Cache queries that don't change
func _ready():
    cached_bullets = world.query([BulletTag])

# ✅ GOOD: Check before get
if entity.has_component(HealthComponent):
    var health = entity.get_component(HealthComponent)

# ⚠️ OK but verbose: Direct get (returns null if missing)
var health = entity.get_component(HealthComponent)
if health:
    print(health.current)
```

## Debugging

```gdscript
# Print all entities
print("Total entities: ", ecs_world.entities.size())

# Print entity components
for comp in entity.get_all_components():
    print("  - ", comp.get_script().resource_path)

# Print system info
for system in ecs_world.systems:
    print("System: ", system.name)
    print("  Cached entities: ", system.cached_entities.size())
    print("  Priority: ", system.priority)

# Watch entity in debugger
print("Entity %d components:" % entity.entity_id)
for key in entity.components:
    print("  ", key)
```

## Common Mistakes

```gdscript
# ❌ WRONG: Storing entity references
class_name MyComponent extends Component
var target_entity: Entity  # BAD! Entity might be destroyed

# ✅ RIGHT: Store entity ID and query
class_name MyComponent extends Component
var target_entity_id: int

# Then query when needed:
var target = world.entities.get(component.target_entity_id)
if target:
    # Use target

# ❌ WRONG: Logic in component
class_name PositionComponent extends Component
var position: Vector2
func move(delta):  # NO! Logic goes in systems
    position += velocity * delta

# ✅ RIGHT: Pure data in component
class_name PositionComponent extends Component
var position: Vector2  # Just data

# ❌ WRONG: Modifying cached_entities while iterating
for entity in cached_entities:
    entity.destroy()  # Modifies cached_entities!

# ✅ RIGHT: Make a copy first
var entities_to_destroy = cached_entities.duplicate()
for entity in entities_to_destroy:
    entity.destroy()
```

## Testing

```gdscript
# Unit test a system
func test_death_system():
    var world = World.new()
    world.add_system(DeathSystem.new())
    
    var entity = world.create_entity()
    entity.add_component(HealthComponent.new(0))  # Dead
    
    world.update(1.0)  # 1 second
    
    # Entity should be destroyed
    assert(not world.entities.has(entity.entity_id))
    print("Test passed!")
```

## Example Game Loop

```gdscript
extends Node2D

var ecs_world: World

func _ready():
    _setup_ecs()
    _create_player()
    _create_enemies(10)

func _setup_ecs():
    ecs_world = World.new()
    add_child(ecs_world)
    
    # Add systems in order
    ecs_world.add_system(InputSystem.new())
    ecs_world.add_system(AISystem.new())
    ecs_world.add_system(CollisionSystem.new())
    ecs_world.add_system(DamageSystem.new())
    ecs_world.add_system(RenderSystem.new())
    ecs_world.add_system(DeathSystem.new())

func _process(delta):
    ecs_world.update(delta)

func _create_player():
    var player = ecs_world.create_entity()
    player.add_component(PlayerTag.new()) \
          .add_component(PositionComponent.new(Vector2(400, 300))) \
          .add_component(SpriteComponent.new("res://player.png")) \
          .add_component(HealthComponent.new(100)) \
          .add_component(InputComponent.new())

func _create_enemies(count: int):
    for i in count:
        var enemy = ecs_world.create_entity()
        enemy.add_component(EnemyTag.new()) \
             .add_component(PositionComponent.new(Vector2(randf() * 800, randf() * 600))) \
             .add_component(SpriteComponent.new("res://enemy.png")) \
             .add_component(HealthComponent.new(50)) \
             .add_component(AIComponent.new())
```

---

**Pro Tip:** Start simple! Add components and systems one at a time. Test each addition before moving to the next.
