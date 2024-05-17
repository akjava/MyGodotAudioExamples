extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
var MIN_DB = 60
var magnitudes = []
var predicts = []
var HEIGHT = 200
var w = 1

var separations = []

var values = [] #for test
func _ready():
	pass # Replace with function body.


func get_energy(index):
	return clamp((MIN_DB + linear_to_db(magnitudes[index])) / MIN_DB, 0, 1)

func _draw():
	draw_rect(Rect2(0,0, magnitudes.size(), 200), Color.BLACK)
	var x = 0
	#print(magnitudes.size())
	for i in range(magnitudes.size()):
		var total = get_energy(i)
		var size = 1
		if i > 0:
			total += get_energy(i-1)
			size += 1
		if i < magnitudes.size()-1:
			total += get_energy(i+1)
			size += 1
		var height = total/size * HEIGHT
		height = get_energy(i) * HEIGHT
		draw_rect(Rect2(w*x,HEIGHT - height, 2, height), Color.WHITE)
		x += 1
	
	draw_predict()	
	
	for separete in separations:
		var start = separete[0]
		var end = separete[1]
		draw_rect(Rect2(w*start,0,w*end - w*start + w,HEIGHT),Color(Color.RED),false)

var last_vy = 0
func draw_predict():
	var last_y = HEIGHT
	for i in range(predicts.size()):
		
		var predict = predicts[i]
		var x = i
		var y = HEIGHT - HEIGHT*predict
		draw_line(Vector2(x,HEIGHT/2),Vector2(x+1,HEIGHT/2),Color.BLUE)
		draw_line(Vector2(x,last_y),Vector2(x+1,y),Color.CYAN)
		last_y = y
		#print("x =%s y=%s"%[x,HEIGHT/2])
		
	for i in range(values.size()):
		var y = HEIGHT - HEIGHT*values[i]
		draw_line(Vector2((i-1)*3,last_vy),Vector2(i*3,y),Color.GRAY)
		last_vy = y

func create_separations():
	var  separate = null
	var enegies = []
	var max_zero_continue = 5
	var first_zero_index
	var zero_continue = 0
	
	for i in range(magnitudes.size()):
		enegies.append(get_energy(i))
		
	for i in range(enegies.size()):
		#print("enegy index %s = %s"%[i,enegies[i]])
		if enegies[i] == 0:
			if separate:
				if zero_continue == 0:
					first_zero_index = i
					#print("zero index = %s"%[i])
					zero_continue = 1
				elif zero_continue < max_zero_continue:
					zero_continue += 1
					#print("continue zero %s max = %s"%[zero_continue,max_zero_continue])
				else:
					separate[1] = first_zero_index-1
					#print("close separate %s"%[first_zero_index-1])
					zero_continue = 0
					separate = null
		else:
			zero_continue = 0
			if separate == null:
				#print("new separate %s"%[i])
				separate = [i,-1]
				separations.append(separate)
				
	if separate:
		if separate[1] == -1:
			if zero_continue > 0:
				separate[1] = first_zero_index-1
			else:
				separate[1] = enegies.size()-1
