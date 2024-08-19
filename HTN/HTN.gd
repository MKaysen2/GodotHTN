# if you're looking for good code, you've come to the wrong place!
class_name HTN
extends Node

var task_queue := Array()
var current_task : TaskContext
var current_plan = []
var plan_step : int = 0
#MTR -> Method Traversal Record aka branch decomp
var current_MTR : Array[int] = [] # A list of the branch decompositions, used to calculate plan priority
@export var is_paused = false

@onready var avatar = get_parent()
var should_replan = true

@export var max_replans_per_tick := 2

@export var bb_node : Blackboard

@export_file("*.htn") var domain_file
var domain : Domain

func get_bb() -> BB:
	return bb_node.get_bb()

func get_args() -> Array[Variant]:
	return [] if current_task == null else current_task.args
	
func _ready() -> void:
	bb_node.updated.connect(on_bb_updated)
	domain = HtnSystem.load_domain(domain_file)
	domain.init_domain(self, avatar)

func on_bb_updated(key):
	if _del_list.has(key) or _add_list.has(key):
		return
		
	queue_replan()

# RUNNING PLANS
func queue_replan():
	should_replan = true

func _should_replan() -> bool:
	return should_replan or current_task == null

func pause():
	is_paused = true
	if current_task and current_task.task and current_task.task.in_progress:
		current_task.task.cancel()
	clear_current_plan()
	queue_replan()

func unpause():
	is_paused = false
	queue_replan()

func clear_current_plan():
	if current_task != null and current_task.task.in_progress:
		current_task.task.cancel()
	current_plan = []
	current_task = null
	current_MTR = []
	plan_step = 0
	_del_list = []
	_add_list = {}

func _process(delta: float) -> void:
	if is_paused:
		return
	if _should_replan():
		plan_and_execute()
	elif current_task: # Don't update on same frame as start?
		current_task.task.update(delta)

func _is_higher_priority_decomp(new : Array[int], curr : Array[int]) -> bool:
	#Lower branch index -> Higher priority
	if curr.size() == 0:
		return true
	for i in range(new.size()):
		if new[i] < curr[i]:
			return true
		elif new[i] > curr[i]:
			return false
	return false # I'm not sure if we need to compare the lengths since the decomp should be the same

func _is_better_plan(result : HTNPlanner.PlannerResult):
	return ((current_task == null and current_plan.size() == 0) or
				_is_higher_priority_decomp(result.MTR, current_MTR))

func plan_and_execute():
	should_replan = false
	var res := replan()
	
	if res.was_success() and _is_better_plan(res):
		if current_task != null and current_task.task.in_progress:
			current_task.task.cancel()
		current_plan = res.plan
		current_MTR = res.MTR
		var status = HTNTaskStatus.Status.SUCCESS
		while status == HTNTaskStatus.Status.SUCCESS:
			status = _start_next_task()
		if status == HTNTaskStatus.Status.FAILURE:
			clear_current_plan()
			queue_replan()
	elif res.was_fail():
		clear_current_plan()
		queue_replan()

func _start_next_task() -> HTNTaskStatus.Status:
	if current_plan.size() == 0 or current_plan.size() <= plan_step:
		return HTNTaskStatus.Status.FAILURE
	current_task = current_plan[plan_step]
	var t : Primitive = current_task.task as Primitive
	_get_fx(t)
	if !t.check(get_bb(), get_args()):
		return HTNTaskStatus.Status.FAILURE
	var s = current_task.task.start()
	if s == HTNTaskStatus.Status.SUCCESS:
		_apply_fx()
		plan_step += 1
	return s

func finish_task(success: bool) -> void:
	if success == false:
		clear_current_plan()
		queue_replan()
	else:
		_apply_fx()
		plan_step += 1
		var status = HTNTaskStatus.Status.SUCCESS
		while status == HTNTaskStatus.Status.SUCCESS:
			status = _start_next_task()
		if status == HTNTaskStatus.Status.FAILURE:
			clear_current_plan()
			queue_replan()

##########
#Effects Handling
#########
var _del_list : Array = []
var _add_list := {}

func _get_fx(task : Primitive):
	_del_list = task.del_list
	_add_list = task.resolve_fx(get_bb(), get_args())

func _apply_fx():
	get_bb().apply_effects(_del_list, _add_list)

# PLANNING

@onready var planner := HTNPlanner.new()

func replan() -> HTNPlanner.PlannerResult:
	return planner.plan(domain, bb_node.get_bb())
