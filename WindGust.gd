extends Line2D


var pf_dict = []
var use_gradient = false

@export var reverse_direction = false
@export var line_segments = 20
@export var trail_length = 1.0 # (float,0.0,1.0)
@export var trail_speed = 0.001
@export var trail_color_gradient : Gradient
@export var random_y_offset = 0.0

func _ready():
	
	if reverse_direction:	
		flip_path()
		
	
	if random_y_offset > 0.0:
		randomize_path()
	
	init_path_followers()
	if trail_color_gradient	!= null:
		use_gradient = true

func _process(delta):
	
	move_path()
	
	if use_gradient:
		update_path_gradient()
		
	draw_path()
	

func flip_path():

	var point_pos = []
	var point_in = []
	var point_out = []

	var curve_points = $Path2D.curve.point_count

	for idx in range(0, curve_points):
		point_pos.append($Path2D.curve.get_point_position(idx))
		point_in.append($Path2D.curve.get_point_in(idx))
		point_out.append($Path2D.curve.get_point_out(idx))
	

	$Path2D.curve.clear_points()

	var jdx = 0
	for idx in range(curve_points-1,-1,-1):
		$Path2D.curve.add_point(point_pos[idx], -point_in[idx], -point_out[idx], jdx)
		jdx += 1
	
func move_path():
	for pf in pf_dict:		
		pf.trail_offset += trail_speed
		if pf.trail_offset >= 0.0 and pf.trail_offset <= 1.0:
			pf.progress_ratio = pf.trail_offset
		
		if pf.trail_offset >= 1.0:
			pf.progress_ratio = 1.0

	if pf_dict[0].progress_ratio == 1.0:
		queue_free()

func update_path_gradient():
		
		for pcnt in range(line_segments+1):
			gradient.colors[pcnt] = trail_color_gradient.sample(gradient.offsets[pcnt])
			gradient.colors[pcnt].a *= trail_color_gradient.sample(pf_dict[pcnt].progress_ratio).a
		

func randomize_path():
	
	randomize()
	
	for i in range($Path2D.curve.point_count):
		var curve_point = $Path2D.curve.get_point_position(i)
		curve_point.y += randf_range(-random_y_offset, random_y_offset)
		$Path2D.curve.set_point_position(i,curve_point)
		
		
func draw_path():	
	clear_points()
	
	for pf in pf_dict:
		#if pf.progress_ratio > 0.0 and pf.progress_ratio < 1.0:
		add_point(pf.global_position)


func init_path_followers():
	
	for pf_cnt in range(line_segments+1):
		var new_pf = TrailFollow2D.new()
		$Path2D.add_child(new_pf)
		new_pf.trail_offset = float(pf_cnt)/float(line_segments)*trail_length - trail_length
		new_pf.loop = false		
		pf_dict.append(new_pf)
	
	gradient = Gradient.new()
	gradient.remove_point(0)

	for g_cnt in range(line_segments):
		gradient.add_point(float(g_cnt+1)/float(line_segments), Color(1.0,1.0,1.0,1.0))
