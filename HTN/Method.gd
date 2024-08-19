class_name Method
extends RefCounted

var pre : Expression
var steps : Array

func check(bb : BB, args : Array) -> bool:
	return pre.execute(args, bb)

func get_subplan(bb : BB, args : Array[Variant]) -> Array[TaskContext]:
	var res : Array[TaskContext] = []
	for s in steps: 
		res.push_back(s.get_context(bb, args))
	return res
