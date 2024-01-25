class_name PlantManager
extends Node2D

@export var player: Player

var _plant_occupied_tiles: Array[Vector2i] = []

func add_plant(coords: Vector2i):
	var check_index = _plant_occupied_tiles.find(coords)
	if check_index == -1:
		_plant_occupied_tiles.append(coords)
		print("Plantmanager added plant: ", coords)

func remove_plant(coords: Vector2i):
	var check_index = _plant_occupied_tiles.find(coords)
	if check_index != -1:
		_plant_occupied_tiles.remove_at(check_index)
		print("Plantmanager added plant: ", coords)

func check_for_plant(coords: Vector2i) -> bool:
	var check_index = _plant_occupied_tiles.find(coords)
	print(_plant_occupied_tiles)
	if check_index != -1:
		return false
	return true
