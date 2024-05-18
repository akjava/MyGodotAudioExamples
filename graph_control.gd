extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var data_dics = []
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

var MIN_DB = 60
func linear_to_energy(value):
	return clamp((MIN_DB + linear_to_db(value)) / MIN_DB, 0, 1)

var last_point
var hz_step = 100
func _draw():
	#draw_rect(Rect2(0,0,200,200),Color.RED)
	var max_height = 20
	var offset_y = 0
	
	#var colors = [
	#Color.WHITE,
	#Color.RED,Color.BLUE,Color.GREEN,Color.GRAY,Color.AQUA,Color.ORANGE,Color.GRAY,Color.BLACK]
	
	for i in data_dics.size():
		#var color = colors[i]
		var color = Color.RED
		var dic = data_dics[i]
		var x  = 0
		last_point = Vector2i(-1,max_height+offset_y)
		var keys = dic.keys()
		
		for key in keys:
			var value = dic[key]
			
			var energy = linear_to_energy(value)
			#energy = energy*energy
			#print("%s = %s"%[key,linear_to_energy(value)])
			var new_point = Vector2i(x,max_height - int(max_height*energy)+offset_y)
			if abs(last_point.x - new_point.x)>6:
				print("invalid %s %s"%[last_point,new_point])
			if energy > 0.5:
				color = Color.RED
			elif energy>0.25:
				color = Color.GREEN
			else:
				color = Color.BLUE
			draw_line(last_point,new_point,color)
			#print(last_point,new_point)
			last_point = new_point
			x+=6
		draw_string(ThemeDB.fallback_font,last_point,"%4d - %4d"%[i*hz_step,(i+1)*hz_step])
		offset_y += max_height
			
