class_name MethodStep
extends RefCounted

var task : TaskBase = null
var args : Array = []

func _init(t : TaskBase, a : Array):
	task = t
	args = a

func get_context(bb: BB, context_args : Array[Variant]) -> TaskContext:
	var resolved_args = []
	for a in args:
		resolved_args.push_back(a.execute(context_args, bb))
	return TaskContext.new(task, resolved_args)
