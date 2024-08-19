class_name TaskContext
extends RefCounted

var task : TaskBase
var args : Array[Variant]

func _init(t : TaskBase, a : Array[Variant]):
	task = t
	args = a
