extends Node

@onready var intro = $Intro
@onready var intro_audio = $IntroAudio


func _ready():
	await intro.animation_finished
	get_tree().change_scene_to_file("res://scene/screen/main_menu.tscn")
	
func play_intro_audio():
	intro_audio.play()
