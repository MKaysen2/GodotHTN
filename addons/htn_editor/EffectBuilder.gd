class_name EffectBuilder
extends Resource

@export var key : String = ''
@export var expr : String = ''

func to_dict() -> Dictionary:
	return {
		'key' : key,
		'expr' : expr
	}

func from_dict(d: Dictionary):
	key = d.get('key', '')
	expr = d.get('expr', '')
