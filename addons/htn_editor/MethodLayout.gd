@tool
class_name MethodLayout
extends VSplitContainer

@export var idx := 0
@export var layout_scene = preload('res://addons/htn_editor/MethodStepLayout.tscn')
@export var tasks : VBoxContainer

var method : MethodBuilder

signal move_up(idx : int)
func _on_move_up():
	move_up.emit(idx)
signal move_down(idx : int)
func _on_move_down():
	move_down.emit(idx)
signal delete(idx : int)
func _on_delete():
	delete.emit(idx)

func _on_name_changed(new_text : String):
	method.name = new_text

func _on_precondition_changed(new_text : String):
	method.precondition = new_text

func open(m  : MethodBuilder):
	method = m
	$HBoxContainer/MethodName.text = method.name
	$HBoxContainer/Precondition.text = method.precondition

	for s in method.plan:
		_add_task(s)

func _on_add_task():
	var step = StepBuilder.new('', [])
	method.plan.push_back(step)
	_add_task(step)

func _add_task(s : StepBuilder):
	var step_view : MethodStepLayout = layout_scene.instantiate()
	tasks.add_child(step_view)
	step_view.open(s)
	step_view.idx = tasks.get_child_count() - 1
	
	step_view.move_up.connect(_on_task_move_up)
	step_view.move_down.connect(_on_task_move_down)
	step_view.delete.connect(_on_remove_task)

func refresh_task_idxs():
	var children = tasks.get_children()
	for i in children.size():
		children[i].idx = i

func _on_remove_task(i : int):
	method.plan.remove_at(i)
	var step_view = tasks.get_child(i)
	tasks.remove_child(step_view)
	step_view.queue_free()
	refresh_task_idxs()

func _on_task_move_up(i : int):
	if i == 0:
		return
	var child = tasks.get_child(i)
	tasks.move_child(child, i - 1)
	method.move_step_up(i)
	refresh_task_idxs()

func _on_task_move_down(i : int):
	if i == tasks.get_child_count() - 1:
		return
	var child = tasks.get_child(i)
	tasks.move_child(child, i + 1)
	method.move_step_down(i)
	refresh_task_idxs()
