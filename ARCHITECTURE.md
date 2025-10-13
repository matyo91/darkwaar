# ECS Architecture Guide

## Overview

This is a **lightweight ECS implementation** designed specifically for Godot 4.5.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                         World                            │
│  ┌───────────────────────────────────────────────────┐  │
│  │                    Systems                         │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────┐ │  │
│  │  │ Movement     │  │ Render       │  │ Death   │ │  │
│  │  │ System       │  │ System       │  │ System  │ │  │
│  │  │ Priority: 10 │  │ Priority: 100│  │ Pri: 200│ │  │
│  │  └──────────────┘  └──────────────┘  └─────────┘ │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  ┌───────────────────────────────────────────────────┐  │
│  │                   Entities                         │  │
│  │  ┌────────┐  ┌────────┐  ┌────────┐  ┌────────┐  │  │
│  │  │Entity 1│  │Entity 2│  │Entity 3│  │Entity 4│  │  │
│  │  └────────┘  └────────┘  └────────┘  └────────┘  │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘

Entity 1 (Player):
  ├── PositionComponent(x:100, y:100)
  ├── VelocityComponent(dx:50, dy:0)
  ├── SpriteComponent(texture:"player.png")
  ├── HealthComponent(hp:100)
  └── InputComponent()

Entity 2 (Enemy):
  ├── PositionComponent(x:300, y:200)
  ├── VelocityComponent(dx:-20, dy:10)
  ├── SpriteComponent(texture:"enemy.png")
  ├── HealthComponent(hp:50)
  └── AIComponent()

Entity 3 (Bullet):
  ├── PositionComponent(x:150, y:150)
  ├── VelocityComponent(dx:200, dy:0)
  └── DamageComponent(amount:25)
```

## Data Flow

```
Frame Start
	↓
┌───────────────────────┐
│ MovementSystem        │  Priority: 10 (runs first)
│   For each entity:    │
│     pos += vel * dt   │
└───────────────────────┘
	↓
┌───────────────────────┐
│ RenderSystem          │  Priority: 100
│   For each entity:    │
│     sprite.pos = pos  │
└───────────────────────┘
	↓
┌───────────────────────┐
│ DeathSystem           │  Priority: 200 (runs last)
│   For each entity:    │
│     if hp <= 0:       │
│       destroy()       │
└───────────────────────┘
	↓
Frame End
```

## Component Lifecycle

```
1. Component Created
   ↓
2. component.on_added(entity)  ← Hook: Initialize
   ↓
3. Component Used by Systems
   ↓
4. component.on_removed(entity) ← Hook: Cleanup
   ↓
5. Component Destroyed
```

## System Caching

Systems maintain a **cached list** of matching entities for performance:

```
World creates Entity:
  └─> Check all Systems
	  └─> If matches required_components:
		  └─> Add to system.cached_entities

Component added to Entity:
  └─> Check all Systems
	  └─> If now matches:
		  └─> Add to system.cached_entities

Component removed from Entity:
  └─> Check all Systems
	  └─> If no longer matches:
		  └─> Remove from system.cached_entities
```

This means systems don't search all entities every frame!

## Performance Characteristics

| Operation | Complexity | Notes |
|-----------|-----------|-------|
| Create entity | O(1) | Just allocate ID |
| Add component | O(S) | S = number of systems |
| Remove component | O(S) | Update system caches |
| System.process() | O(N) | N = matching entities only |
| Query entities | O(E) | E = total entities |

## Example: Player Entity

```gdscript
# Create player
var player = ecs_world.create_entity()

# Add components (can chain!)
player.add_component(PositionComponent.new(Vector2(100, 100))) \
      .add_component(VelocityComponent.new(Vector2.ZERO)) \
      .add_component(SpriteComponent.new("res://player.png")) \
      .add_component(HealthComponent.new(100)) \
      .add_component(InputComponent.new())

# Access components
var pos = player.get_component(PositionComponent)
pos.position = Vector2(200, 200)

# Check component
if player.has_component(HealthComponent):
    print("Player is alive!")

# Remove component
player.remove_component(VelocityComponent)

# Destroy entity
player.destroy()
```

## Example: Custom System

```gdscript
class_name DamageSystem
extends System

func _init() -> void:
    required_components = [HealthComponent, PositionComponent]
    priority = 150

func process(delta: float) -> void:
    # Get all entities that can take damage
    for entity in cached_entities:
        var health = entity.get_component(HealthComponent)
        var pos = entity.get_component(PositionComponent)
        
        # Check for damage zones
        if _is_in_fire(pos.position):
            health.take_damage(10 * delta)

func _is_in_fire(position: Vector2) -> bool:
    # Your logic here
    return false
```

## Best Practices

### ✅ DO:
- Keep components as **pure data** (no logic)
- Put all logic in **systems**
- Use **priority** to control system order
- Query entities in systems, not every frame
- Use `cached_entities` for system-specific entities

### ❌ DON'T:
- Don't put game logic in components
- Don't access other entities directly (use queries)
- Don't store references to entities (they may be destroyed)
- Don't forget to check `has_component()` before `get_component()`

## Common Patterns

### Pattern 1: Event System
```gdscript
# Event component
class_name DamageEvent
extends Component
var amount: int
var source: Entity

# Damage processing system
class_name DamageProcessingSystem
extends System

func process(delta: float) -> void:
	# Process entities with damage events
	for entity in world.query([DamageEvent, HealthComponent]):
		var event = entity.get_component(DamageEvent)
		var health = entity.get_component(HealthComponent)
		
		health.take_damage(event.amount)
		entity.remove_component(DamageEvent)  # Clear event
```

### Pattern 2: State Machine Component
```gdscript
class_name StateComponent
extends Component
enum State { IDLE, WALKING, ATTACKING }
var current_state: State = State.IDLE
var state_time: float = 0.0
```

### Pattern 3: Tag Components
```gdscript
# Just markers, no data
class_name PlayerTag extends Component
class_name EnemyTag extends Component
class_name BulletTag extends Component

# Query by tag
var enemies = world.query([EnemyTag, PositionComponent])
```

## Comparison with Other Approaches

| | **This ECS** | **Pure Godot Nodes** | **Heavy ECS Addon** |
|---|--------------|---------------------|---------------------|
| **Setup** | ⭐⭐⭐⭐⭐ Simple | ⭐⭐⭐⭐ Easy | ⭐⭐ Complex |
| **Performance** | ⭐⭐⭐⭐ Good | ⭐⭐⭐ OK | ⭐⭐⭐⭐⭐ Excellent |
| **Flexibility** | ⭐⭐⭐⭐⭐ High | ⭐⭐⭐ Medium | ⭐⭐⭐⭐⭐ High |
| **Debugging** | ⭐⭐⭐⭐ Easy | ⭐⭐⭐⭐⭐ Very Easy | ⭐⭐ Hard |
| **Learning Curve** | ⭐⭐⭐⭐ Gentle | ⭐⭐⭐⭐⭐ None | ⭐⭐ Steep |
| **Integration** | ⭐⭐⭐⭐⭐ Native | ⭐⭐⭐⭐⭐ Native | ⭐⭐⭐ OK |

## When to Use This ECS

✅ **Good for:**
- Games with many similar entities (bullets, particles, enemies)
- Need runtime flexibility (add/remove behaviors)
- Want separation of data and logic
- Performance matters (1000+ entities)

❌ **Not needed for:**
- Simple games with < 100 entities
- Menu systems, UI
- One-off unique objects
- Quick prototypes

## Migration from Node-Based

```gdscript
# BEFORE (Node-based)
class_name Player
extends CharacterBody2D

var health: int = 100
var speed: float = 200

func _physics_process(delta):
	velocity = Input.get_vector(...) * speed
	move_and_slide()

# AFTER (ECS)
# Components:
# - PositionComponent
# - VelocityComponent
# - HealthComponent
# - InputComponent

# Systems:
# - InputSystem: reads input, sets velocity
# - MovementSystem: updates position from velocity
# - RenderSystem: syncs sprite to position
```

## Next Steps

1. **Try the demo**: Run `demo/ecs_demo.tscn`
2. **Create components**: Add your own in `components/`
3. **Create systems**: Add your own in `systems/`
4. **Experiment**: Mix and match components!

## FAQ

**Q: Can entities be Godot nodes?**
A: Yes! Entities extend Node, so they appear in the scene tree.

**Q: Can I use Godot's physics?**
A: Yes! Create a PhysicsBodyComponent that wraps CharacterBody2D.

**Q: How do I handle collisions?**
A: Create a CollisionSystem that checks entities with CollisionComponent.

**Q: Can I save/load entities?**
A: Yes! Serialize components to JSON/binary.

**Q: Performance with 10,000 entities?**
A: Should be fine. Use system caching and test. Consider pooling.
