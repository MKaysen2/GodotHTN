@tool
extends Panel

class ASTNode extends RefCounted:
	var val = ""
	var children = []
	
	func _to_string() -> String:
		return ToString(0)

	func ToString(lvl):
		var str = ""
		for i in lvl:
			str += '\t'
		str += str(val) + '\n'
		for c in children:
			str += c.ToString(lvl+1)
		return str

func open_domain():
	pass

func on_compile():
	var tokens = $CodeEdit.text.replace('(', ' ( ')
	tokens = tokens.replace(')', ' ) ')
	tokens = tokens.replace('\n', '')
	tokens = tokens.replace('\n', '')
	tokens = tokens.split(' ') as Array
	tokens = tokens.filter(func(s): return s != '')
	
	var head := ASTNode.new()
	var curr_node = head
	curr_node.val = tokens[0]
	var ast_stack = []
	var i = 1
	while i < len(tokens):
		if tokens[i] == '(':
			var new_node: = ASTNode.new()
			#TODO: Check for EOF
			new_node.val = tokens[i + 1]
			curr_node.children.push_back(new_node)
			ast_stack.push_back(curr_node)
			curr_node = new_node
			i += 2
		elif tokens[i] == ')':
			#TODO: Check for empty stack
			curr_node = ast_stack.pop_back()
			i += 1
		else:
			var new_node = ASTNode.new()
			new_node.val = tokens[i]
			curr_node.children.push_back(new_node)
			i += 1
	
	print(head)
	var curr_task_name = ""
	var parsed_Domain = {}
	print(tokens)


func _on_button_pressed() -> void:
	on_compile()
