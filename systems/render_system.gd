## Render System - Syncs sprite position with entity position
class_name RenderSystem
extends System


func _init() -> void:
	# Needs both Position and Sprite components
	required_components = [PositionComponent, SpriteComponent]
	priority = 100  # Run late (after movement)


func process(delta: float) -> void:
	# Sync sprite position with entity position
	for entity in cached_entities:
		var pos = entity.get_component(PositionComponent) as PositionComponent
		var sprite_comp = entity.get_component(SpriteComponent) as SpriteComponent
		
		if sprite_comp.sprite:
			sprite_comp.sprite.position = pos.position

