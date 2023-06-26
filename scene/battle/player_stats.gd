extends Node

var BattleUnits = preload("res://scene/resource/battle_units.tres")
@onready var low_health = $LowHealth
@onready var heal_ready = $HealReady

signal hp_changed(value)
signal ap_changed(value)
signal sp_changed(value)


var max_hp = 37
var max_ap = 2
var max_sp = 12
var min_atk = 6
var max_atk = 8
var guard = false
var heal_executed = false

signal turn_end

var hp = max_hp:
	set(value):
		hp = clamp(value,0,max_hp)
		emit_signal("hp_changed",value)
		if hp <=15:
			low_health.play()
		elif hp >15:
			low_health.stop()
		elif hp <= 0:
			emit_signal("player_death")
var ap = max_ap:
	set(value):
		ap = clamp(value,0,max_ap)
		emit_signal("ap_changed",value)
		if ap == 0:
			emit_signal("turn_end")
var sp = 0:
	set(value):
		sp = clamp(value,0,max_sp)
		emit_signal("sp_changed",value)
		if sp >= 8 and not heal_executed:
			heal_ready.play()
			heal_executed = true
		if sp <8 :
			heal_executed = false
func _ready():
	BattleUnits.Player = self
	
func _exit_tree():
	BattleUnits.Player = null
