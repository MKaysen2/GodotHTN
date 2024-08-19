class_name MethodBuilder
extends Resource

@export var name : String = ''
@export var precondition : String = ''
@export var plan : Array = []

func ToString() -> String:
	var res = '\t' + name + ': \n'
	res += '\t\t' + precondition + '\n'
	for s in plan:
		res += s.ToString()
	return res

func to_dict() -> Dictionary:
	return {
		'name' : name,
		'precondition' : precondition,
		'plan' : plan.map(func(s): return s.to_dict())
	}

func from_dict(d : Dictionary):
	name = d.get('name', '')
	precondition = d.get('precondition', '')
	plan = d.get('plan', []).map(_step_from_dict)

func _step_from_dict(d : Dictionary):
	var step = StepBuilder.new('', [])
	step.from_dict(d)
	return step

func add_new_step() -> StepBuilder:
	var step = StepBuilder.new('', [])
	plan.push_back(step)
	return step

func move_step_up(i : int):
	_swap(i, i-1)

func move_step_down(i :int):
	_swap(i, i+1)

func _swap(i0, i1):
	var temp = plan[i0]
	plan[i0] = plan[i1]
	plan[i1] = temp
