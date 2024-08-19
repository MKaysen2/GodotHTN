class_name Primitive
extends TaskBase

var in_progress := false
var precondition : Expression
var del_list : Array
var add_list : Array[HTNEffect]

func compile(_dom: Domain, d : Dictionary):
	precondition = Expression.new()
	precondition.parse(d['precondition'], d['arg_names'])
	del_list = d['del_list']
	for e in d['add_list']:
		var expr = Expression.new()
		expr.parse(e['expr'], d['arg_names'])
		add_list.push_back(HTNEffect.new(e['key'], expr))
	for p in d['params']:
		var expr = Expression.new()
		expr.parse(d['params'][p])
		var val = expr.execute()
		set(p, val)

func check(bb : BB, args : Array[Variant]):
	return precondition.execute(args, bb)

func resolve_fx(bb : BB, args : Array[Variant]) -> Dictionary:
	var res = {}
	for e in add_list:
		res[e.key] = e.expr.execute(args, bb)
	return res

func get_bb() -> BB:
	return htn.get_bb()

func get_args() -> Array[Variant]:
	return htn.get_args()

func _arg(i) -> Variant:
	return htn.get_args()[i]

func start() -> HTNTaskStatus.Status:
	in_progress = true
	return _start_task()

#Override this method, 
func _start_task() -> HTNTaskStatus.Status:
	printerr("_start_task not implemented for " + name + "!")
	return HTNTaskStatus.Status.FAILURE

func update(_delta : float):
	pass

#ignores think rate
func physics_update(_delta : float):
	pass

func finish(success: bool) -> void:
	in_progress = false
	htn.finish_task(success)
func cancel():
	in_progress = false
