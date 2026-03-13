extends Control


func _ready():
	visible = false

func _on_button_pressed():
	#get_tree().change_scene_to_file("res://Scense/node_2d.tscn")
	Score.reset_score()
	PlayerHealth.reset()
	MouseEnergy.reset()
	visible = false
	get_tree().call_group("enemy", "queue_free")
	get_tree().reload_current_scene()
