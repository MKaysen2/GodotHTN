class_name Domain
extends RefCounted

var tasks : Dictionary # [String, TaskBase]

func get_root():
	return tasks['root']

func is_continue(task):
	return tasks.has('continue') and tasks['continue'] == task

func compile(d):
	tasks = {}
	for k in d['tasks'].keys():
		var task_dict = d['tasks'][k]
		var new_task
		if task_dict['is_compound']:
			new_task =Compound.new()
		else:
			new_task = load(task_dict['script_path']).new()
		new_task.name = k
		tasks[k] = new_task
	
	tasks['continue'] = Primitive.new()
	tasks['succeed'] = Succeed.new()

	for k in d['tasks'].keys():
		tasks[k].compile(self, d['tasks'][k])

func init_domain(htn : HTN, avatar : Node):
	for task in tasks.values():
		task.htn = htn
		task.avatar = avatar
