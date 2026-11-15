extends Control

@export var largura_grid: int = 3 # e.g. shotgun (escopeta) = 3x2
@export var altura_grid: int = 2
var grid_pos: Vector2i = Vector2i(-1, -1)
var rotacionado: bool = false

@onready var sprite:Sprite2D =$Sprite2D
func _ready() -> void:
	pass

func rotacionar() -> void:
	rotacionado = !rotacionado
	
	# Swaps width (largura) and height (altura) on the grid (grade)
	var temp = largura_grid
	largura_grid = altura_grid
	altura_grid = temp
	
	# Updates the visual size of the item's container (e.g. 48px per cell)
	size = Vector2(largura_grid, altura_grid) * 48
	
	# Rotates only the image's visual around the center
	sprite.pivot_offset = sprite.size / 2
	sprite.rotation_degrees = 90 if rotacionado else 0
