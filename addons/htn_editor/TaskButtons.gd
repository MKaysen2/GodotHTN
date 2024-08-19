@tool
class_name TaskButtons
extends HBoxContainer

var idx : int

signal open_task(idx, is_compound)
signal name_updated(text)
signal delete(idx)

func update_name(text : String):
	$OpenTask.text = text
	$NameEdit.text = text

func _on_delete_pressed():
	delete.emit(idx)

func _on_open_task():
	open_task.emit(idx)
	#$OpenTask.visible = false
	#$NameEdit.visible = true

func _on_name_edited(text):
	$OpenTask.text = text

func close():
	$OpenTask.visible = true
	$NameEdit.visible = false
