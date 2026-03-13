extends Control
var Score = 0

func _ready():
	update_score()
	

func update_score():
	$Score_number.text = str(Score)
	
func reset_score():
	Score = 0
	update_score()
