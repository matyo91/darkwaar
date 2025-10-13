# Darkwaar

A Godot 4.5 project with Entity-Component-System (ECS) architecture.

## ECS Structure

```
ecs/
  ├── component.gd     # Base component class
  ├── entity.gd        # Entity (container for components)
  ├── system.gd        # Base system class
  └── world.gd         # World (manages entities & systems)

components/
  ├── position_component.gd
  ├── sprite_component.gd
  └── health_component.gd

systems/
  ├── render_system.gd
  └── death_system.gd

demo/
  ├── ecs_demo.gd      # Example usage
  └── ecs_demo.tscn    # Demo scene
```

## Quick Start

### 1. Create a World

```gdscript
var ecs_world = World.new()
add_child(ecs_world)
```

### 2. Add Systems

```gdscript
ecs_world.add_system(RenderSystem.new())
ecs_world.add_system(DeathSystem.new())
```

### 3. Create Entities

```gdscript
var player = ecs_world.create_entity()
player.add_component(PositionComponent.new(Vector2(100, 100)))
player.add_component(SpriteComponent.new("res://icon.svg"))
player.add_component(HealthComponent.new(100))
```

### 4. Update Each Frame

```gdscript
func _process(delta: float) -> void:
    ecs_world.update(delta)
```

## Creating Custom Components

```gdscript
class_name MyComponent
extends Component

var my_data: int = 0

func _init(data: int = 0) -> void:
    my_data = data
```

## Creating Custom Systems

```gdscript
class_name MySystem
extends System

func _init() -> void:
    required_components = [MyComponent, PositionComponent]
    priority = 50  # Lower = runs first

func process(delta: float) -> void:
    for entity in cached_entities:
        var my_comp = entity.get_component(MyComponent) as MyComponent
        var pos = entity.get_component(PositionComponent) as PositionComponent
        # Your logic here
```

## Querying Entities

```gdscript
# Get all entities with specific components
var enemies = ecs_world.query([HealthComponent, AIComponent])
for enemy in enemies:
    var health = enemy.get_component(HealthComponent)
    print("Enemy HP: %d" % health.current)
```

## Demo

Run `demo/darkwaar5.tscn` or `demo/darkwaar6.tscn` to see the ECS in action:
- Entities with various components
- Entity dying after 3 seconds
- Press SPACE to query entity states

## Architecture Benefits

✅ **Simple** - Easy to understand, minimal code
✅ **Flexible** - Add/remove components at runtime
✅ **Performant** - Cached entity queries per system
✅ **Godot-friendly** - Works with Godot's node system
✅ **Debuggable** - Entities visible in scene tree

## License

MIT
