extends Control


@onready var cover_back =$Energy_image/Control/Energy_back 
@onready var cover_E = $Energy_image/Control/Energy_E
var max_energy = 100.0
var current_energy = 100.0
var drain_rate = 70.0		# 每秒消耗多少 (按住時)
var recharge_rate = 45.0 	# 每秒回充多少 (放開時)
var can_grab = true			# 給外部 (Player) 讀取的變數
var original_Energy = 0
func _ready():
	original_Energy = cover_E.size.x

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if current_energy > 0:
			current_energy -= drain_rate * delta
			can_grab = true
		else:
			current_energy = 0
			can_grab = false
	else:
		if current_energy < max_energy:
			current_energy += recharge_rate * delta
		else:
			current_energy = max_energy
	updata_ui()

func updata_ui():	#這邊是算能量圖片的大小變化
	if original_Energy == 0:
		return
	# 避免還沒準備好就執行	# 遮罩寬度 = 總寬度 * (1 - 剩餘比例)
	var energy_percent = current_energy / max_energy
	cover_E.size.x = original_Energy * energy_percent
	
func reset():
	current_energy = max_energy
