extends Node2D

func _on_slash_animation_finished(_anim_name):
	queue_free()
