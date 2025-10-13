## Death System - Destroys entities with 0 health
class_name DeathSystem
extends System


func _init() -> void:
	required_components = [HealthComponent]
	priority = 200  # Run last


func process(delta: float) -> void:
	# Check all entities with health
	# Create array copy to avoid modification during iteration
	var entities_to_check = cached_entities.duplicate()
	
	for entity in entities_to_check:
		var health = entity.get_component(HealthComponent) as HealthComponent
		
		if not health.is_alive():
			print("Entity %d died!" % entity.entity_id)
			entity.destroy()
