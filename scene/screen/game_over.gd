extends Node

@onready var swipe = $Control/SwipeScreenButton
@onready var timer = $Timer
@onready var fade = $AnimationPlayer
@onready var bg = $ColorRect
@onready var gover = $GameOver
@onready var gover_audio = $GameOverAudio
@onready var door = $Door

var swipe_detected = false
var swipe_cooldown = 0.1

func _ready():
	gover_audio.play()

func _input(event):
	if event is InputEventScreenDrag:
		if swipe_detected == false:
			var swipe_direction = swipe.get_swipe_direction(event.relative, 4)
			##swipe up
			if swipe_direction == Vector2.UP:
				fade.play("fade game over")
				door.play()
				await fade.animation_finished
				get_tree().change_scene_to_file("res://scene/battle/battle.tscn")
			##swipe dowm
			elif swipe_direction == Vector2.DOWN:
				fade.play("fade game over")
				await fade.animation_finished
				get_tree().change_scene_to_file("res://scene/screen/main_menu.tscn")
			##swipe left
			elif swipe_direction == Vector2.LEFT:
				print("swipe left")
			##swipe right
			elif swipe_direction == Vector2.RIGHT:
				print("swipe right")
			
			swipe_detected = true
			timer.start(swipe_cooldown)  # Start the cooldown timer

func _on_timer_timeout():
	swipe_detected = false

func hide_image():
	gover.hide()
	bg.hide()
