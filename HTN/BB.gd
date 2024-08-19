class_name BB
extends Resource

var data : Dictionary

func k(key : String) -> Variant:
	return data.get(key)
	
func val(key : String, value : Variant = null) -> Variant:
	return data.get(key, value)

func has(key : String) -> bool:
	return data.has(key)

func nil(key : String) -> bool:
	return !data.has(key)

func eq(key : String, value : Variant) -> bool:
	return data.has(key) and typeof(data[key]) == typeof(value) and data[key] == value

func neq(key : String, value: Variant) -> bool:
	return !eq(key, value)

func gt(key : String, value : Variant) -> bool:
	return data.has(key) and typeof(data[key]) == typeof(value) and data[key] > value

func lt(key : String, value : Variant) -> bool:
	return data.has(key) and typeof(data[key]) == typeof(value) and data[key] < value

func geq(key : String, value : Variant) -> bool:
	return data.has(key) and typeof(data[key]) == typeof(value) and data[key] >= value

func leq(key : String, value : Variant) -> bool:
	return data.has(key) and typeof(data[key]) == typeof(value) and data[key] <= value

func dist_to_pt(key :String, value: Vector2) -> float:
	if data[key] is Node2D:
		return value.distance_to(data[key].global_position)
	return value.distance_to(data[key])

func apply_effects(del_list : Array, add_list: Dictionary):
	for key in del_list:
		data.erase(key)
	for key in add_list:
		data[key] = add_list[key]

func duplicate_data():
	return data.duplicate(true)
