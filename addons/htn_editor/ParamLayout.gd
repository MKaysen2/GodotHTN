@tool
class_name ParamLayout
extends HBoxContainer

signal value_updated(prop_name : String, val : String)

var prop_name := ""
func open(param_name, initial_val= ""):
	$Label.text = param_name
	$LineEdit.text = initial_val
	prop_name = param_name

func _on_lineedit_text_changed(text: String) -> void:
	value_updated.emit(prop_name, text)
