class_name HTNPlanner
extends RefCounted

var tasks_to_process := []
var working_plan : Array[TaskContext] = []
var working_bb = null

# Subplan information
var sub_idx := 0
var sub_len := 1
var decomp_stack := []
var next_branch := 0
var MTR : Array[int] # Method Traversal Record, stack of branch decomps

func plan(domain : Domain, bb : BB) -> PlannerResult:
	var res := _get_plan(domain, bb)
	_clear_planner_state()
	return res

class PlannerResult extends RefCounted:
	var plan : Array[TaskContext] = []
	var result : HTNPlanner.ResultStatus
	var MTR : Array[int] = []
	
	func was_success():
		return result == ResultStatus.SUCCESS
	
	func was_continue():
		return result == ResultStatus.CONTINUE
	
	func was_fail():
		return result == ResultStatus.FAIL

enum ResultStatus {
	FAIL,
	SUCCESS,
	CONTINUE
}

class Decomp extends RefCounted:
	var bb : Dictionary
	var task : TaskContext
	var method_idx : int
	var working_plan_size : int
	var pending_tasks_size : int
	var sub_idx : int
	var sub_len : int
	var MTR_size : int

func _get_plan(domain: Domain, bb : BB) -> PlannerResult:
	var res = PlannerResult.new()
	
	var root = TaskContext.new( domain.get_root(), [])
	
	working_bb = BB.new()
	working_bb.data = bb.duplicate_data()

	tasks_to_process = [root]
	
	while !tasks_to_process.is_empty():
		
		var ctxt : TaskContext = tasks_to_process.pop_front()
		var task = ctxt.task
		var args := ctxt.args

		# TODO: Bind args in a way that doesn't affect the running task
		# I HAAAAAAAAAAAAATE the amouunt of dict passing
		# Turns out I CAN make refcounted inner classes so
		
		if task is Compound:
			var method = task.find_method(working_bb, args, next_branch)
			if method.has('subplan'):
				save_decomp(ctxt, method.branch_idx)
				tasks_to_process = method.subplan + tasks_to_process
				next_branch = 0
			elif !restore_last_decomp():
				return res

		elif task is Primitive:
			if domain.is_continue(task):
				res.status = ResultStatus.CONTINUE
				return res
			if !task.check(working_bb, args):
				if !restore_last_decomp():
					return res
			else:
				working_plan.push_back(ctxt)
				working_bb.apply_effects(task.del_list, task.resolve_fx(working_bb, ctxt.args))
				sub_idx += 1
				# was this the end of 1 or more subplans?
				while sub_idx == sub_len and decomp_stack.size() > 0:
					_pop_decomp()
					sub_idx += 1
		else:
			print("HTN::replan: Error: task is not an HTN task")
			return res

	if working_plan.size() == 0:
		return res
	res.plan = working_plan
	res.result = ResultStatus.SUCCESS
	res.MTR = MTR.duplicate()
	return res

func save_decomp(task, method_idx):
	var record = Decomp.new()
	record.bb = working_bb.duplicate_data()
	record.task = task
	record.method_idx = method_idx
	record.working_plan_size = working_plan.size()
	record.pending_tasks_size = tasks_to_process.size()
	record.sub_idx = sub_idx
	record.sub_len = sub_len
	record.MTR_size = MTR.size()
	
	MTR.push_back(method_idx)
	next_branch = 0
	decomp_stack.push_back(record)

func restore_last_decomp():
	if decomp_stack.size() <= 0:
		return false
	var record = decomp_stack.pop_back()
	working_bb.data = record.bb
	working_plan = working_plan.slice(0, record.working_plan_size)
	var t2p_size = tasks_to_process.size()
	tasks_to_process = tasks_to_process.slice(t2p_size - record.pending_tasks_size, t2p_size)
	tasks_to_process.push_front(record.task)
	next_branch = record.method_idx + 1
	MTR = MTR.slice(0, record.MTR_size)
	sub_idx = record.sub_idx
	sub_len = record.sub_len
	return true

## Called when a method has successfully been decomposed and all subtasks succeed
## Used to prevent a failed compound restoring to a previous compound from the same subplan
func _pop_decomp():
	var decomp = decomp_stack.pop_back()
	sub_idx = decomp.sub_idx
	sub_len = decomp.sub_len

func _clear_planner_state():
	decomp_stack = []
	working_plan = []
	tasks_to_process = []
	next_branch = 0
	MTR = []
	sub_idx = 0
	sub_len = 0
