extends Control

@export var questions = [
	{
		"question": "เดลสูงเท่าไหร่?",
		"options": {"A": "142 ซม", "B": "142 ชม.", "C": "142 ม.", "D": "142 มม."},
		"answer": "A",
		"points": 142
	},
	{
		"question": "1 + 1 เท่ากับเท่าไร?",
		"options": {"A": "1", "B": "2", "C": "3", "D": "4"},
		"answer": "B",
		"points": 10
	},
	{
		"question": "เลขใดมากที่สุด?",
		"options": {"A": "5", "B": "10", "C": "8", "D": "7"},
		"answer": "B",
		"points": 10
	},
	{
		"question": "ประเทศไทยมีฤดูกี่ฤดู?",
		"options": {"A": "2", "B": "3", "C": "4", "D": "5"},
		"answer": "B",
		"points": 10
	},
	{
		"question": "วันในหนึ่งสัปดาห์มีกี่วัน?",
		"options": {"A": "5", "B": "6", "C": "7", "D": "8"},
		"answer": "C",
		"points": 10
	},
	{
		"question": "2 × 5 เท่ากับเท่าไร?",
		"options": {"A": "10", "B": "12", "C": "8", "D": "15"},
		"answer": "A",
		"points": 10
	},
	{
		"question": "หากมีแอปเปิ้ล 4 ลูก กินไป 1 ลูก เหลือกี่ลูก?",
		"options": {"A": "2", "B": "3", "C": "4", "D": "1"},
		"answer": "B",
		"points": 10
	},
	{
		"question": "เลขใดคือเลขคู่?",
		"options": {"A": "3", "B": "7", "C": "4", "D": "9"},
		"answer": "C",
		"points": 10
	},
	{
		"question": "5 + 0 เท่ากับเท่าไร?",
		"options": {"A": "0", "B": "10", "C": "5", "D": "1"},
		"answer": "C",
		"points": 10
	},
	{
		"question": "ในหนึ่งวันมีกี่ชั่วโมง?",
		"options": {"A": "24", "B": "12", "C": "60", "D": "30"},
		"answer": "A",
		"points": 10
	}
]

var shuffled_questions = []
var current_question_index = 0
var score = 0
var max_timer = 60 # วินาที
var time_per_question = 1 # วินาที

@onready var labelQuestion = $Question
@onready var buttonChoices = [$ButtonA, $ButtonB, $ButtonC]
@onready var labelFeedback = $Feedback
@onready var scoreLable = $Score
@onready var restart_button = $RestartButton
@onready var back_button = $BackButton
@onready var image_rect = $TextureRect

@onready var timer = $Timer
@onready var timerLabel = $TimeCounter


func _ready():
	restart_button.pressed.connect(restart_game)
	back_button.pressed.connect(on_click_back)
	timerLabel.text = ""
	set_default_color_and_image()
	start_game()

func _process(_delta: float) -> void:
	var time_left = timer.time_left
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	var microseconds = int((time_left - int(time_left)) * 1000)

	if minutes < 1 and seconds <= 10:
		timerLabel.text = "เวลาคงเหลือ: %02d.%03d" % [seconds, microseconds]
	else:
		timerLabel.text = "เวลาคงเหลือ: %02d:%02d" % [minutes, seconds]

	if time_left <= 0.0:
		current_question_index = shuffled_questions.size()
		timer.stop()
		load_question()
		labelQuestion.text = "เวลาหมดแล้ว!!!"
		scoreLable.text = "คะแนน: %d" % score
		timerLabel.text = ""

func start_game():
	timerLabel.text = "เวลาคงเหลือ: " 
	restart_button.visible = false
	shuffled_questions = questions.duplicate()
	shuffled_questions.shuffle()
	current_question_index = 0
	timer.one_shot = true
	timer.wait_time = max_timer
	timer.start()
	load_question()

func restart_game():
	score = 0
	start_game()

func load_question():
	set_default_color_and_image()
	
	scoreLable.text = "คะแนน: %d" % score
	if current_question_index >= shuffled_questions.size():
		# labelQuestion.text = "🎉 คุณตอบคำถามครบแล้ว! คะแนนของคุณ: %d" % score
		labelQuestion.text = ""
		labelFeedback.text = ""
		for button in buttonChoices:
			button.visible = false
		restart_button.visible = true
		return

	var question_data = shuffled_questions[current_question_index]
	labelQuestion.text = "ข้อที่ %d: %s" % [min(current_question_index + 1, shuffled_questions.size()), question_data["question"]]

	var keys = ["A", "B", "C"]
	for i in keys.size():
		var key = keys[i]
		var btn = buttonChoices[i]
		btn.visible = false
		btn.text = "%s" % question_data["options"][key]
		if btn.pressed.is_connected(handle_answer_wrapper):
			btn.pressed.disconnect(handle_answer_wrapper)
		btn.pressed.connect(handle_answer_wrapper.bind(key))
		btn.visible = true

	labelFeedback.text = ""

func handle_answer_wrapper(selected_key: String):
	handle_answer(selected_key)

func handle_answer(selected_key: String):
	var question_data = shuffled_questions[current_question_index]
	var answer_key = question_data["answer"]
	if selected_key == answer_key:
		labelFeedback.text = "✅ ถูกต้อง!!"
		score += question_data["points"]
		scoreLable.text = "คะแนน: %d" % score
	else:
		labelFeedback.text = "❌ ผิดนะ คำตอบที่ถูกคือ: %s" % question_data["options"][answer_key]

	set_background_image(selected_key, selected_key == answer_key)

	current_question_index += 1
	await get_tree().create_timer(time_per_question).timeout
	load_question()

func set_button_color(name_str: String, color_code: String):
	var color = Color(color_code)
	for btn in buttonChoices:
		btn.add_theme_color_override(name_str, color)

func set_all_labels_color(name_str: String, color_code: String):
	var color = Color(color_code)
	labelQuestion.add_theme_color_override(name_str, color)
	labelFeedback.add_theme_color_override(name_str, color)
	scoreLable.add_theme_color_override(name_str, color)



func set_background_image(choice: String, is_correct: bool):
	var disabled_color = Color("#1234FF")
	var choiced_color = Color("#1234FF") # black green
	var btn_index = 0
	if is_correct:
		if choice == "A":
			image_rect.texture = load("res://assets/quiz_game/ตอบถูกซ้าย.png")
			btn_index = 0
		elif choice == "B":
			image_rect.texture = load("res://assets/quiz_game/ตอบถูกกลาง.png")
			btn_index = 1
		elif choice == "C":
			image_rect.texture = load("res://assets/quiz_game/ตอบถูกขวา.png")
			btn_index = 2
		disabled_color =  Color("#000000")	
		choiced_color = Color("#00FF00")
	else:
		if choice == "A":
			image_rect.texture = load("res://assets/quiz_game/ตอบผิดซ้าย.png")
			btn_index = 0
		elif choice == "B":
			image_rect.texture = load("res://assets/quiz_game/ตอบผิดกลาง.png")
			btn_index = 1
		elif choice == "C":
			image_rect.texture = load("res://assets/quiz_game/ตอบผิดขวา.png")
			btn_index = 2
		set_all_labels_color("font_color", "#FFFFFF")
		set_button_color("font_color", "#FFFFFF")
		set_button_color("font_focus_color", "#FFFFFF")
		disabled_color = Color("#FF0000")
		choiced_color = Color("#FFFFFF")

	for btn in buttonChoices:
		btn.add_theme_color_override("font_disabled_color", disabled_color)
		btn.disabled = true

	buttonChoices[btn_index].add_theme_color_override("font_disabled_color", choiced_color)

func set_default_color_and_image():
	image_rect.texture = load("res://assets/quiz_game/question_screen.png")
	set_all_labels_color("font_color", "#000000")
	set_button_color("font_color", "#000000")
	set_button_color("font_disabled_color", "#1234FF")

	# func set_button_hover_font_color():
	var hover_color = Color("#a3a3a3")
	for btn in buttonChoices:
		btn.add_theme_color_override("font_color_hover", hover_color)
		btn.disabled = false

func on_click_back():
	# get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	score = 0
	start_game()

func time_left_to_live() -> Array:
	var timeleft = timer.time_left
	var minutes = float(timeleft / 60)
	var seconds = int(timeleft) % 60
	var microseconds = int(timeleft * 1000) % 1000
	return [minutes, seconds, microseconds]
