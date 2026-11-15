extends Control
var linhas = 7
var colunas = 5
var cellsize = 35
func _draw() -> void:
	for i in range(0,linhas,1):
		var posicaox = i * 35
		draw_rect(Rect2(posicaox,0,cellsize,cellsize),Color.AQUAMARINE,false)
		for j in range(0,colunas,1):
			var posicaoy = j * 35
			
			draw_rect(Rect2(posicaox,posicaoy,cellsize,cellsize),Color.AQUAMARINE,false)
var grade: Array = [] # 2D matrix that stores what is in each square

func _ready() -> void:
	# Initializes the whole matrix as empty (null)
	for x in range(colunas):
		grade.append([])
		for y in range(linhas):
			grade[x].append(null)

# Checks whether an item fits at position (pos_x, pos_y) with size (largura = width, altura = height)
func pode_encaixar(pos_x: int, pos_y: int, largura: int, altura: int, item_ignorado = null) -> bool:
	# 1. Checks whether it goes outside the edges of the case (maleta)
	if pos_x < 0 or pos_y < 0 or pos_x + largura > colunas or pos_y + altura > linhas:
		return false
	
	# 2. Checks whether any required square is already taken by another item
	for x in range(pos_x, pos_x + largura):
		for y in range(pos_y, pos_y + altura):
			if grade[x][y] != null and grade[x][y] != item_ignorado:
				return false
				
	return true

# Registers the item in the matrix and places it visually
func colocar_item(item: Control, pos_x: int, pos_y: int, largura: int, altura: int) -> void:
	for x in range(pos_x, pos_x + largura):
		for y in range(pos_y, pos_y + altura):
			grade[x][y] = item
			
	item.position = Vector2(pos_x, pos_y) * cellsize
	item.grid_pos = Vector2i(pos_x, pos_y)

# Clears the old position when the player starts dragging the item
func remover_item_da_grade(item: Control, pos_x: int, pos_y: int, largura: int, altura: int) -> void:
	for x in range(pos_x, pos_x + largura):
		for y in range(pos_y, pos_y + altura):
			if grade[x][y] == item:
				grade[x][y] = null
