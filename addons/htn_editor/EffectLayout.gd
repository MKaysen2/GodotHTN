@tool
class_name EffectLayout
extends HBoxContainer

var idx : int
var effect : EffectBuilder
func open(e: EffectBuilder):
	effect = e
	$Key.text = e.key
	$Expr.text = e.expr

signal delete(i : int)
func _on_delete_pressed():
	delete.emit(idx)

func _on_key_changed(text : String):
	effect.key = text

func _on_expr_changed(text : String):
	effect.expr = text
