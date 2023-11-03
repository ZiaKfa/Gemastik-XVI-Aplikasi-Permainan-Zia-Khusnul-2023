extends Node

const SAVEFILE = "user://savefile.save"

var highest_score = 0

func _ready():
	load_score()

func save_score():
	var file = FileAccess.open(SAVEFILE,FileAccess.WRITE_READ)
	file.store_32(highest_score)
	
	
func load_score():
	var file = FileAccess.open(SAVEFILE,FileAccess.READ)
	if FileAccess.file_exists(SAVEFILE):
		highest_score = file.get_32()
