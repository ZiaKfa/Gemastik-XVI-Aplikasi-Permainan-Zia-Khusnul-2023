extends Node

@onready var log_text = $UIBase/Log/LogText
@onready var swipe = $UIBase/SwipeScreenButton
@onready var timer = $Timer
@onready var fade = $AnimationPlayer
@onready var door = $Door
@onready var slash_sound = $Slash
@onready var miss = $Miss
@onready var heal_sound = $Heal
@onready var shield_sound = $Shield
@onready var low_health = $UIBase/LowHealthOverlay
@onready var battle_log = $UIBase/Log/LogText
@onready var negative = $Negative
@export var enemies:Array[PackedScene]

var BattleUnits = preload("res://scene/resource/battle_units.tres")
const RightSlash = preload("res://scene/effect/slash_effect_right.tscn")
const LeftSlash = preload("res://scene/effect/slash_effect_left.tscn")
const HealEffect = preload("res://scene/effect/heal_effect.tscn")
const HitEffect = preload("res://scene/effect/hit_effect.tscn")
const ShieldEffect = preload("res://scene/effect/shield.tscn")

var player_turn = false

##start battle
func _ready():
	randomize()
	create_new_enemy()

##starting enemy turn
func start_player_turn():
	player_turn = true
	var player = BattleUnits.Player
	player.ap = player.max_ap
	await player.turn_end
	start_enemy_turn()

##starting enemy turn
func start_enemy_turn():
	var enemy = BattleUnits.Enemy
	if enemy != null:
		player_turn = false
		enemy.attack()
		await enemy.end_turn
		start_player_turn()

	
##attacking enemy
func attackenemy(attack_side):
	var side_id
	if attack_side == "left":
		side_id = "kiri"
	else :
		side_id = "kanan"
	var enemy = BattleUnits.Enemy
	var player = BattleUnits.Player
	print("side = " + enemy.side)
	if enemy != null:
		player.ap -=1
		print("player ap = " + str(player.ap))
		if enemy.side == attack_side:
			var player_damage = randi_range(player.min_atk,player.max_atk)
			enemy.take_damage(player_damage)
			create_hit(attack_side)
			slash_sound.play()
			print("player attack " + str(player_damage) + " damage")
			player.sp += 3
			log_text.text = "Zedd menyerang ke " + side_id + " (kena)"
			print("player sp = " + str(player.sp))
		else :
			miss.play()
			enemy.get_side()
			enemy.play_idle()
			log_text.text = "Zedd menyerang ke " + side_id + " (tidak kena)"
		
func heal():
	var player = BattleUnits.Player
	if player != null:
		if player.sp>=8 && player.hp < player.max_hp:
			var heal_amount = randi_range(6,10)
			player.hp += heal_amount
			create_heal()
			player.sp -= 8
			player.ap -= 1
			heal_sound.play()
			print("player heal " + str(heal_amount) + "hp")
			log_text.text = "Zedd melakukan heal"
			print("player hp = " + str(player.hp))
			print("player ap = " + str(player.ap))
			print("player sp = " + str(player.sp))
		elif player.sp<8:
			log_text.text = "Energi tidak cukup"
			negative.play()
		elif player.hp == player.max_hp:
			log_text.text = "HP Zedd penuh"
			negative.play()

func shield():
	var player = BattleUnits.Player
	if player != null:
		player.ap -= 1
		print("player ap = " + str(player.ap))
		player.guard = true
		shield_sound.play()
		create_shield()
		print("guard")
		log_text.text = "Zedd menggunakan perisai"

##swipe control
var swipe_detected = false
var swipe_cooldown = 0.12  # Set the cooldown period in seconds

func _input(event):
	var enemy = BattleUnits.Enemy
	if event is InputEventScreenDrag:
		if swipe_detected == false:
			var swipe_direction = swipe.get_swipe_direction(event.relative, 2.5)
			##swipe up
			if swipe_direction == Vector2.UP:
				if enemy != null:
					if BattleUnits.Player.guard == false:
						shield()
					else :
						log_text.text = "Perisai sudah diangkat"
						negative.play()
				else :
					enter_new_room()
			##swipe dowm
			elif swipe_direction == Vector2.DOWN:
				if player_turn:
					heal()
			##swipe left
			elif swipe_direction == Vector2.LEFT:
				var slash_pos
				if enemy != null && player_turn:
					attackenemy("left")
					slash_pos = Vector2(-10,40)
					create_slash(slash_pos,"left")
			##swipe right
			elif swipe_direction == Vector2.RIGHT:
				var slash_pos = Vector2()
				if enemy != null && player_turn:
					attackenemy("right")
					slash_pos = Vector2(30,40)
					create_slash(slash_pos,"right")
			
			swipe_detected = true
			timer.start(swipe_cooldown)  # Start the cooldown timer

func _on_timer_timeout():
	swipe_detected = false

func create_new_enemy():
	var rand_rng = randi_range(0,2)
	var Enemy = enemies[rand_rng]
	var enemy = Enemy.instantiate()
	self.add_child(enemy)
	BattleUnits.Player.ap = BattleUnits.Player.max_ap
	print("enemy hp = " + str(enemy.hp))
	log_text.text = enemy.description
	start_player_turn()

func create_slash(pos,side_slash):
	var slash
	if side_slash == "right":
		slash = RightSlash.instantiate()
	elif side_slash == "left":
		slash = LeftSlash.instantiate()
	var battle = get_tree().current_scene
	battle.add_child(slash)
	slash.global_position = pos

func create_heal():
	var heal_effect = HealEffect.instantiate()
	var battle = get_tree().current_scene
	battle.add_child(heal_effect)
	heal_effect.global_position = Vector2.ZERO

func create_shield():
	var shield_effect = ShieldEffect.instantiate()
	var battle = get_tree().current_scene
	battle.add_child(shield_effect)
	shield_effect.global_position = Vector2.ZERO

func create_hit(side_hit):
	var hit = HitEffect.instantiate()
	if side_hit == "left":
		hit.global_position = Vector2(10,65)
	elif side_hit == "right":
		hit.global_position = Vector2(60,65)
	var battle = get_tree().current_scene
	battle.add_child(hit)

func enter_new_room():
	fade.play("fade'")
	door.play()
	await fade.animation_finished
	create_new_enemy()

func _process(_delta):
	var player = BattleUnits.Player
	if player.hp <=0:
		low_health.hide()
		fade.play("fade battle")
		await fade.animation_finished
		game_over()
	elif player.hp <=15:
		low_health.show()
	elif player.hp >15:
		low_health.hide()
		
func game_over():
	get_tree().change_scene_to_file("res://scene/screen/game_over.tscn")
	
func hide_logo():
	pass

