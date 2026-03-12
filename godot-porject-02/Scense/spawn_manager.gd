extends Node2D
var enemy_scene = preload("res://Scense/Enemy_scene.tscn")
var rng = RandomNumberGenerator.new()
func _ready():
	rng.randomize()
	
func _on_timer_timeout():
	spawn_mob()
	
func spawn_mob():
	#生成怪物
	var enemy  = enemy_scene.instantiate()
	#決定左右邊
	var R_OR_L = rng.randi_range(0,1)
	#取得畫面寬度 (這樣不管解析度多少都能用)
	#生成位子
	var spawn_x = 0.0
	var is_from_left = true
	#生成方向
	if R_OR_L == 0:
		spawn_x = -900 # 左邊畫面外
		is_from_left = true
		#print("有跑出來往右")
	else:
		spawn_x = 900 # 右邊畫面外
		is_from_left = false
		#print("有跑出來往左")
	add_child(enemy)
	#print("有生怪物")
	
	enemy.start_moving(spawn_x,226, is_from_left)
