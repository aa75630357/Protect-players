extends RigidBody2D
#判斷是否有被滑鼠托拽
var is_dragging  = false
#判斷抓人物的哪個點
var local_grab_pos = Vector2.ZERO
#抓到的速度
var dragging_speed = 25.0
#這邊是手感參數,拉力強度
var pull_power = 20.0
#阻尼：控制甩動
var damp = 1.0
#移動
var run_speed = 150.0
#死亡線
var Death_limit = 1100.0
#移動方向 是用生成管理員呼叫時候會給對應數值
var move_direction = 0 #1 -1 右左
#隨機幫我骰
var Rng = RandomNumberGenerator.new()
#砲彈衝擊的速度 (數值越大衝越快，可以自己微調)
var cannonball_speed = 300.0
var jump_more = 0.0
var harder_harder = 0 
var speed_up = 0.0
var is_locked_on = false
var wants_to_attack = false

# 1. 尋找玩家 (在場景中找屬於 "Player" 群組的節點)

func _ready():
	#可以平移
	lock_rotation = true
	#每次偵測是否一直按住滑鼠
	input_pickable = true
	#重力
	gravity_scale = 1
	#確保阻力不要太大
	linear_damp = 1.0
	speed_up = 0.0
	jump_more = 0.0
	harder_harder = 0 
	is_locked_on = false
	wants_to_attack = false
	calculate_difficulty()
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	#這是看input也就是hitbox有增測到什麼
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		
			if event.pressed:	#鎖定滑鼠點位
				if MouseEnergy.can_grab:
					is_dragging = true
					local_grab_pos = to_local(get_global_mouse_position())
				else:
					is_dragging = false
	
#自動走路的部分
func start_moving(spawn_x: float ,spawn_y: float ,is_from_left: bool,):
	#設定出生點
	global_position = Vector2(spawn_x,spawn_y)
	#看要往又跳還是左跳這是出生
	var NY_jump = Rng.randi_range(0,100)
	var random_jump_height = 0.0
	if NY_jump > 30:
		random_jump_height =Rng.randf_range(-0.3,-1.0)
	#隨機塗層會在後面或前線
	var hide_or_not_Rng = RandomNumberGenerator.new()
	hide_or_not_Rng.randomize()
	if hide_or_not_Rng.randi_range(0,1) == 0:
		z_index = -5
	else:
		z_index = 5
		
	var direction = Vector2.ZERO
	if is_from_left:
		move_direction = 1  # 往右
	else:
		move_direction = -1 # 往左
	apply_impulse(direction.normalized() * run_speed)

#放手單獨處理因為會有人物hitbox還沒到屬標上屬標就放開了不會曾測到所以要全域的
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			is_dragging = false

func _physics_process(delta):
		#當被抓到時候會停止AI
	if is_dragging:
			if not MouseEnergy.can_grab:
				is_dragging = false
			else: #當被抓到時候會停止AI
				var mouse_pos = get_global_mouse_position()
				var current_grab_pos = to_global(local_grab_pos)
				var diff = mouse_pos - current_grab_pos
				var force = (diff * pull_power) - (linear_velocity * damp)
				apply_impulse(force, current_grab_pos - global_position)
				return
				
	#這邊是判斷能量是否耗光
	if is_dragging and not MouseEnergy.can_grab:
		is_dragging = false
	#死亡
	var players = get_tree().get_nodes_in_group("player")
	if (global_position.x < -Death_limit or 
	global_position.x > Death_limit or 
	global_position.y > Death_limit) and players.size() > 0:
		queue_free()
		Score.Score += 1
		Score.update_score()
		
	if Score.Score > 20 and global_position.y < -150 and not is_locked_on:
		if Rng.randi_range(0, 1) == 0:
			launch_at_player()
			is_locked_on = true # 標記已發射，避免重複執行		
	if abs(linear_velocity.y) < 10:
		is_locked_on = false
		
	
	
	#自動移動
	if abs(linear_velocity.x) < run_speed:
		apply_force(Vector2(move_direction * 2000.0, 0)) # 給一個推力
	#隨機跳躍
	if randf() < (0.015 + jump_more) and abs(linear_velocity.y) < 10:
		var jump_force = randf_range(-500.0 , -1500.0)	#隨機跳躍高度
		var random_x_push = randf_range(-200 - speed_up, 200 + speed_up)		#隨機看要不要轉向
		# 執行跳躍
		apply_impulse(Vector2(random_x_push, jump_force))
		# 跳的時候順便轉一下身 (增加動感)
		apply_torque_impulse(move_direction * 200.0)
		
	calculate_difficulty()
func get_direction_to_player():
	var players = get_tree().get_nodes_in_group("player")
	# 2. 確保有找到玩家
	if players.size() > 0:
		var target_player = players[0]
		# 3. 計算方向向量：(目標位置 - 自己位置)
		var direction_vector = target_player.global_position - global_position
		# 4. 正規化：把向量長度變成 1，只保留方向資訊
		return direction_vector.normalized()
	# 如果玩家不存在，返回一個零向量 (避免錯誤)
	return Vector2.ZERO

func launch_at_player():
	# 1. 取得指向玩家的標準方向向量 (呼叫工具 1)
	var direction = get_direction_to_player()
	# 2. 只有在方向不是零 (即玩家存在) 時才發射
	if direction != Vector2.ZERO:
		
		# 清除原本的動能 (讓衝擊更純粹，避免被原本走路的速度干擾)
		linear_velocity = Vector2.ZERO 
		
		# 施加衝力：方向向量 * 速度
		apply_impulse(direction * cannonball_speed)
		print("發射！")
		
		# (選用) 鎖定旋轉，讓它不會在空中亂滾
		lock_rotation = true

func calculate_difficulty():
	# 算出目前是第幾個 10 分 (例如 50 分就是 5 等)
	var difficulty_level = int(Score.Score / 5)
	
	if difficulty_level > 0:
		# 1. 跳更高：每級增加 300 力道 (注意這裡是正數，下面再去減)
		Engine.time_scale = clamp(1.0 + (difficulty_level * 0.1), 1.0, 3.0)
		# 2. 跑更快：每級增加 50 速度
		speed_up = difficulty_level * 100.0
		
		# 3. 更愛跳：每級增加 0.5% 機率
		jump_more = difficulty_level * 0.005
		
func _on_body_entered(body):
	if body.is_in_group("player"):
		print("撞到玩家！")

		# 2. 玩家彈飛
		var push_dir = (body.global_position - global_position).normalized()
		body.apply_impulse(push_dir * 800.0)
		
		# 3. 怪物自己彈飛 (這樣就不會黏住)
		var bounce_dir = (global_position - body.global_position).normalized()
		linear_velocity = Vector2.ZERO # 清除原本衝刺速度
		apply_impulse(bounce_dir * 1000.0)
