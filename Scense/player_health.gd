extends Control
@onready var health_bar = $Control/Health_E
# 1. 定義訊號：玩家死亡
signal player_died
var max_hp = 100.0
var current_hp = 100.0
var initial_width = 0.0

func _ready():
	if health_bar:
		initial_width = health_bar.size.x

func _take_damage(amount):
	print("扣血了")
	current_hp -= amount
	if current_hp <= 0 :
		current_hp = 0
		player_died.emit()
	update_ui()
	
func update_ui():
	if initial_width == 0: return
	
	var hp_percent = current_hp / max_hp
	health_bar.size.x = initial_width * hp_percent
	
func reset():
	current_hp = max_hp
	update_ui()
