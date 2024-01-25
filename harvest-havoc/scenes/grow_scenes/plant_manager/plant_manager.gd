class_name PlantManager
extends Node2D

var _plant_occupied_tiles: Array[Vector2i] = []

func add_plant(coords: Vector2i):
	var check_index = _plant_occupied_tiles.find(coords)
	if check_index == -1:
		_plant_occupied_tiles.append(coords)

func remove_plant(coords: Vector2i):
	var check_index = _plant_occupied_tiles.find(coords)
	if check_index != -1:
		_plant_occupied_tiles.remove_at(check_index)

func check_for_plant(coords: Vector2i) -> bool:
	var check_index = _plant_occupied_tiles.find(coords)
	if check_index != -1:
		return false
	return true
