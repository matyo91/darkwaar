## Movement System - Updates position based on velocity
class_name MovementSystem
extends System


func _init() -> void:
	# Define what components this system needs
	required_components = [PositionComponent, VelocityComponent]
	priority = 10  # Run early


func process(delta: float) -> void:
	# Process all entities with Position + Velocity
	for entity in cached_entities:
		var pos = entity.get_component(PositionComponent) as PositionComponent
		var vel = entity.get_component(VelocityComponent) as VelocityComponent
		
		# Update position
		pos.position += vel.velocity * delta
