extends RigidBody2D

#被攻擊後無敵一下
var is_invincible = false
var invincibility_time = 1.0 # 無敵 1 秒

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
#掉到世界外面
var Dealth_line_y = 2000.0
var Dealth_line_x = 610

func _ready():
	#每次偵測是否一直按住滑鼠
	input_pickable = true
	#重力
	gravity_scale = 1
	# ★關鍵：訂閱 PlayerHealth 的死亡訊號
	# 意思就是：當 PlayerHealth 發出 "player_died" 時，執行我的 "_on_death" 函式
	PlayerHealth.player_died.connect(_on_death)
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	#這是看input也就是hitbox有增測到什麼
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.pressed:		#這邊是按一下會固定住然後再按一次會鬆開
			#抓住的時候
			#is_dragging = true
			#關掉重力
			#gravity_scale = 0
			#這是線性阻尼 也就是線性飛行後會有阻力這樣
			#linear_damp = 5
		#else:
			#放開後恢復
			#is_dragging = false
			#gravity_scale = 1
			#linear_damp = 0
			if event.pressed:	#鎖定滑鼠點位
				if MouseEnergy.can_grab:
					is_dragging = true
					local_grab_pos = to_local(get_global_mouse_position())
#放手單獨處理因為會有人物hitbox還沒到屬標上屬標就放開了不會曾測到所以要全域的
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			is_dragging = false

func _physics_process(delta):
	#這邊是判斷能量是否耗光
	if is_dragging and not MouseEnergy.can_grab:
		is_dragging = false
	#這邊是物理
	if is_dragging:
# 1. 計算滑鼠現在在哪 (目標點)
		var mouse_pos = get_global_mouse_position()
		# 2. 計算您原本抓的那個點，現在轉到哪裡去了 (目前點)
		# to_global 會把剛才記錄的相對座標，算回現在的世界座標 (包含旋轉後的結果)
		var current_grab_pos = to_global(local_grab_pos)
		# 3. 計算距離向量 (從「目前點」指向「滑鼠」)
		var diff = mouse_pos - current_grab_pos
		# 4. 施加物理衝量 (Impulse) - 這就是「提線木偶」的線
		# 我們不直接改速度，而是給它一個力，讓它飛向滑鼠
		# diff * pull_power : 距離越遠拉力越大 (P控制)
		# - linear_velocity * damp : 減去目前速度作為阻尼，防止震盪 (D控制)
		var force = (diff * pull_power) - (linear_velocity * damp)
		# 關鍵 2：apply_impulse(力的大小, 施力點的偏移量)
 		# 因為力是施加在「抓取點」而不是「中心點」，所以物體會自然旋轉 (Swinging)！
		apply_impulse(force, current_grab_pos - global_position)
	#世界外死亡呼叫
	if global_position.y > Dealth_line_y or global_position.x > 610 or global_position.x < -610:
		PlayerHealth._take_damage(9999)


func _on_body_entered(body: Node):
	if is_invincible:
		return
	if body.is_in_group("enemy"):
		PlayerHealth._take_damage(20)
		var push_dir = (global_position - body.global_position).normalized()
		apply_impulse(push_dir * 800.0)
		start_invincibility()
func start_invincibility():
	is_invincible = true
	# 建立一個 Tween 動畫這是godot 4工具
	var tween = create_tween()
	for i in range(5):		#modulate:a透明度
		tween.tween_property($Sprite2D, "modulate:a", 0.2, 0.1) # 變透明
		tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.1) # 變回來	
	#等待無敵恢復$
	await get_tree().create_timer(invincibility_time).timeout
	# 恢復正常
	is_invincible = false
	$Sprite2D.modulate.a = 1.0 # 確保完全不透明
	
func _on_death():
	EndGame.visible = true
	queue_free()
