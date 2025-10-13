## Sprite Component - Links to a Sprite2D node
class_name SpriteComponent
extends Component

var sprite: Sprite2D = null
var texture_path: String = ""


func _init(tex_path: String = "") -> void:
	texture_path = tex_path


func on_added(entity: Entity) -> void:
	# Create sprite when component is added
	sprite = Sprite2D.new()
	entity.add_child(sprite)
	
	if texture_path != "":
		sprite.texture = load(texture_path)


func on_removed(entity: Entity) -> void:
	# Clean up sprite when component is removed
	if sprite:
		sprite.queue_free()
		sprite = null
