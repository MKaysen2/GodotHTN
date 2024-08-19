extends Node

var _loaded_domains = {}

func load_domain(domain_path : String):
	if !_loaded_domains.has(domain_path):
		var file := FileAccess.open(domain_path, FileAccess.READ)
		var dict = file.get_var()
		file = null
		_loaded_domains[domain_path] = dict
	var new_domain = Domain.new()
	new_domain.compile(_loaded_domains[domain_path])
	return new_domain
