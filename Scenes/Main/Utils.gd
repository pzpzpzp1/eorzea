extends Node

static func load_json_file(filename):
	var json_as_text = FileAccess.get_file_as_string(filename)
	var json_data = JSON.parse_string(json_as_text)
	return json_data
