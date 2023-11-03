extends Node

@onready var swipe = $Control/SwipeScreenButton
@onready var timer = $Timer
@onready var fade = $AnimationPlayer
@onready var logo = $Logo
@onready var title = $Title
@onready var door = $Door
@onready var tutorial = $Tutorial/TutorialFade
@onready var credit = $Credit/CreditFade
@onready var voice = $VoiceOver
@onready var tutorial_voice = $TutorialVoice
@onready var high_score_text = $Control/HighScore

var tutorial_onscreen = false
var credit_onscreen = false

var swipe_detected = false
var swipe_cooldown = 0.1

func _ready():
	voice.play()
	high_score_text.text = str(Score.highest_score)

func _input(event):
	if event is InputEventScreenDrag:
		if swipe_detected == false:
			var swipe_direction = swipe.get_swipe_direction(event.relative, 4)
			##swipe up
			if swipe_direction == Vector2.UP:
				fade.play("fade'")
				door.play()
				await fade.animation_finished
				get_tree().change_scene_to_file("res://scene/battle/battle.tscn")
			##swipe dowm
			elif swipe_direction == Vector2.DOWN:
				print("swipe down")
			##swipe left
			elif swipe_direction == Vector2.LEFT:
				if credit_onscreen == false && tutorial_onscreen == false:
					credit.play("fadein")
					credit_onscreen = true
				elif tutorial_onscreen == true:
					tutorial.play("fadeout")
					tutorial_voice.stop()
					await get_tree().create_timer(0.5).timeout
					voice.play()
					tutorial_onscreen = false
				print("swipe left")
			##swipe right
			elif swipe_direction == Vector2.RIGHT:
				if tutorial_onscreen == false && credit_onscreen == false:
					voice.stop()
					tutorial.play("fadein")
					await tutorial.animation_finished
					tutorial_voice.play()
					tutorial_onscreen = true
				elif credit_onscreen == true:
					credit.play("fadeout")
					credit_onscreen = false
				print("swipe right")
			
			swipe_detected = true
			timer.start(swipe_cooldown)  # Start the cooldown timer

func _on_timer_timeout():
	swipe_detected = false

func hide_logo():
	if logo != null:
		logo.hide()
		title.hide()
