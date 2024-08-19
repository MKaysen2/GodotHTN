class_name Compound
extends TaskBase

var methods : Array[Method]

func find_method(bb : BB, args : Array[Variant], last_branch_idx := 0) -> Dictionary:
	# resume search from last decomp
	# This might not be right, might want to start from the last_branch_idx + 1
	for i in range(last_branch_idx, methods.size()):
		var method = methods[i]
		var result = method.check(bb, args)
		if result:
			return {
				'branch_idx' : i,
				'subplan' : method.get_subplan(bb, args)
			}
	return {}

func compile(dom : Domain, d : Dictionary):
	for m in d['methods']:
		var new_method = Method.new()
		#new expr
		new_method.pre = Expression.new()
		new_method.pre.parse(m['precondition'], d['arg_names'])

		# generate method steps
		new_method.steps = []
		for step in m['plan']:
			var exprs = []
			for arg in step['args']:
				var arg_expr = Expression.new()
				arg_expr.parse(arg, d['arg_names'])
				exprs.push_back(arg_expr)

			var method_step = MethodStep.new(
				dom.tasks[step['task_name']],
				exprs)
			new_method.steps.push_back(method_step)
		methods.push_back(new_method)
