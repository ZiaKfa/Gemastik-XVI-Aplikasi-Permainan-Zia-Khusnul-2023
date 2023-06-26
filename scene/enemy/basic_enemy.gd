extends Node2D

var BattleUnits = preload("res://scene/resource/battle_units.tres")
const EnemyHit = preload("res://scene/effect/enemy_attack_effect.tscn")
const NextRoom = preload("res://scene/screen/next_room.tscn")

@onready var hit_player = $HitPlayer
@onready var argh = $Argh
@onready var death_sound = $Death
@onready var left_hit = $Left
@onready var right_hit = $Right
@onready var description_audio = $Description
@onready var next_room_audio = $NextRoom

var on_screen = false

@export var description: String = ""


signal death
signal end_turn

#attacking a target
@export var enemy_damage = 0

var side

func get_side():
	var side_rng = randi_range(1,2)
	if side_rng == 1:
		side = "left"
	else :
		side = "right"

func play_idle():
	if side == "left":
		left_hit.play()
		await left_hit.finished
	elif side == "right":
		right_hit.play()

func attack() -> void:
	var player = BattleUnits.Player
	await get_tree().create_timer(1).timeout
	if on_screen :
		create_hit_enemy()
		if player.guard == false:
			player.hp -= enemy_damage
			hit_player.play()
			argh.play()
		elif player.guard == true:
			player.hp -= floor(enemy_damage * 0.5)
			player.guard = false
			hit_player.play()
		print("enemy attack " + str(enemy_damage) + " damage")
		print("player hp = " + str(BattleUnits.Player.hp))
		await get_tree().create_timer(1).timeout
		emit_signal("end_turn")

##death signal
func is_dead():
	return hp<=0

#taking damage
func take_damage(amount):
	get_side()
	await get_tree().create_timer(0.5).timeout
	play_idle()
	self.hp -= amount
	if is_dead():
		emit_signal("death")
		on_screen = false
		death_sound.play()
		next_room_audio.play()
		await next_room_audio.finished
		await death_sound.finished
		var next_room = NextRoom.instantiate()
		get_tree().current_scene.add_child(next_room)
		next_room.global_position = Vector2.ZERO
		queue_free()

func create_hit_enemy():
	var enemy_hit = EnemyHit.instantiate()
	var battle = get_tree().current_scene
	battle.add_child(enemy_hit)
	enemy_hit.global_position = Vector2(42,95)
	await get_tree().create_timer(0.5).timeout
	play_idle()

##hpsetter
@export var hp = 25:
	set(newhp):
		hp = newhp
		print("enemy hp = " + str(hp))

func _ready():
	BattleUnits.Enemy = self
	on_screen = true 
	description_audio.play()
	await description_audio.finished
	get_side()
	play_idle()
	
func _exit_tree():
	BattleUnits.Enemy = null

