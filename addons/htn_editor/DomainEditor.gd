@tool
extends HBoxContainer

var compound_ed_scene = preload('res://addons/htn_editor/CompoundEditor.tscn')
var primitive_ed_scene = preload('res://addons/htn_editor/PrimitiveEditor.tscn')
var button_scene = preload('res://addons/htn_editor/TaskButtons.tscn')
@export var task_buttons : Control
@export var dir_path_button : Button
@export var select_prim_dialog : FileDialog
@export var select_base_path_dialog : FileDialog
@export var select_domain_builder : FileDialog
@export var domain_name : LineEdit
@export var scroll_container : ScrollContainer
var current_editor = null
var domain : DomainBuilder

func _ready():
	domain = DomainBuilder.new()

func open(d : DomainBuilder):
	domain = d
	for child in task_buttons.get_children():
		task_buttons.remove_child(child)

	for t in d.tasks:
		_add_task_button(t.task_name)
	dir_path_button.text = 'SetBasePath' if d.base_path == '' else d.base_path
	domain_name.text = d.domain_name

func _on_compile_pressed():
	print(domain.ToString())

#DOMAIN NAME
func _on_name_changed(text: String):
	domain.domain_name = text

#SAVING/LOADING
func _on_save_pressed():
	var path = domain.base_path + '/' + domain.domain_name + '.htn'
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_var(domain.to_dict())
	file = null

func _on_load_pressed():
	select_domain_builder.show()

func _on_domain_builder_selected(path):
	var file := FileAccess.open(path, FileAccess.READ)
	var dict = file.get_var()
	file = null
	domain.from_dict(dict)
	open(domain)

func _on_base_path_pressed():
	select_base_path_dialog.show()

func _on_base_path_dialog_selected(path):
	domain.base_path = path
	select_prim_dialog.root_subfolder = path
	dir_path_button.text = path
	

#ADDING TASKS
func _on_add_primitive():
	select_prim_dialog.show()

func _on_primitive_file_selected(path):
	var task = PrimitiveBuilder.new()
	task.script_path = path
	domain.tasks.push_back(task)
	_add_task_button(task.task_name)

func _on_add_compound():
	var task := CompoundBuilder.new()
	domain.tasks.push_back(task)
	_add_task_button(task.task_name)

func _add_task_button(task_name : String):
	var buttons : TaskButtons = button_scene.instantiate()
	task_buttons.add_child(buttons)
	buttons.update_name(task_name)
	buttons.idx = task_buttons.get_child_count() - 1
	buttons.open_task.connect(_on_open_task)
	buttons.delete.connect(_on_delete_task)

func _on_open_task(i : int):
	if current_editor != null:
		scroll_container.remove_child(current_editor)
	var new_scene
	if domain.tasks[i].is_compound:
		new_scene = compound_ed_scene.instantiate()
	else:
		new_scene = primitive_ed_scene.instantiate()
	scroll_container.add_child(new_scene)
	new_scene.idx = i
	new_scene.task_name_changed.connect(_on_task_name_changed)
	new_scene.open(domain.tasks[i])
	current_editor = new_scene

func refresh_button_idxs():
	for i in task_buttons.get_child_count():
		task_buttons.get_child(i).idx = i
	

func _on_delete_task(i : int):
	if current_editor != null:
		if current_editor.idx == i:
			return
		current_editor.idx = i
	var button = task_buttons.get_child(i)
	task_buttons.remove_child(button)
	button.queue_free()
	domain.tasks.remove_at(i)
	refresh_button_idxs()
	
func _on_task_name_changed(new_name : String, index : int):
	task_buttons.get_child(index).update_name(new_name)
