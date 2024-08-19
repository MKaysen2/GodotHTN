class_name HTNEffect
extends RefCounted

var key : String
var expr : Expression
var is_postcond := false

func _init(k : String, e : Expression):
	key = k
	expr = e
