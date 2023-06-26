extends Node2D

func _on_hit_animation_finished(_anim_name):
	queue_free()
