@tool
class_name MethodStepLayout
extends HBoxContainer

var method_step : StepBuilder = null
var idx := 0

signal move_up(idx : int)
signal move_down(idx : int)
signal delete(idx : int)
func on_move_up():
	move_up.emit(idx)
func on_move_down():
	move_down.emit(idx)
func on_delete():
	delete.emit(idx)


func open(step : StepBuilder):
	method_step = step
	$TaskName.text = method_step.task_name
	for i in range(0, method_step.args.size()):
		var line = LineEdit.new()
		line.expand_to_text_length = true
		line.text = method_step.args[i]
		$Args.add_child(line)
		line.text_changed.connect(on_arg_changed.bind(i))

func on_task_name_changed(text : String):
	method_step.task_name = text

func on_arg_changed(text : String, arg_idx : int):
	method_step.args[arg_idx] = text

func on_add_arg():
	var line = LineEdit.new()
	line.expand_to_text_length = true
	method_step.args.push_back('')
	$Args.add_child(line)
	line.text_changed.connect(on_arg_changed.bind(method_step.args.size() - 1))

func on_remove_arg():
	var i = $Args.get_child_count() - 1
	if i > 0:
		var line = $Args.get_child(i)
		line.queue_free()
		method_step.args.pop_back()
