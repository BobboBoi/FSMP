extends Control

@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var analyzer : AudioEffectSpectrumAnalyzerInstance
@onready var window : Window = get_window()
@onready var lineObject := %Line

#@export var width : float = 750;
@export var samples := 320;
@export var height := 350;

@export var line = true
@export var lineYOrigin := 0.0
var flexOrigin := 0.0


const FREQ_MAX = 11050.0/2
@export var MIN_DB = 60 #80
const LERP : float = 0.4

var lastPos : Array
var prevHz := 0.0
var processing := true

func _ready():
	if !resized.is_connected(SizeUpdate): resized.connect(SizeUpdate)
	if !player.Paused.is_connected(Paused): player.Paused.connect(Paused)
	if !player.Resumed.is_connected(Resumed): player.Resumed.connect(Resumed)
	
	analyzer = AudioServer.get_bus_effect_instance(1,0)
	flexOrigin = lineYOrigin
	
	lastPos.resize(samples)

func _process(_delta):
	if window.mode == window.Mode.MODE_MINIMIZED: return
	queue_redraw()

func _draw():
	if !processing: return
	var division = size.x/(samples-1)
	prevHz = 0.0
	#var division = (width*1.015)/samples 
	
	lineObject.clear_points()
	lineObject.position.x = division
	for i in range(0,samples):
		var hz = i * (FREQ_MAX / samples)
		
		#Gets the frequency at the positin hz
		var magnitude: float = analyzer.get_magnitude_for_frequency_range(prevHz, hz).length()
		
		#Turn magnitude to decibels and set max and min values between 0 and 1
		#MIN_DB + linear_to_db(magnitude)) / MIN_DB is the value clamp just limits it
		var energy = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		
		#Calculate height
		var final = energy*height
		var lerpHeight : float
		if lastPos[i-1] != null:
			lerpHeight = lerp(final as float ,lastPos[i-1] as float, LERP)
		else:
			lerpHeight = final
		lastPos[i-1] = lerpHeight as float
		
		if line:
			lineObject.add_point(Vector2(division*i -6,lerpHeight*-1 + flexOrigin))
		else:
			draw_rect(Rect2(division * i, size.y, division, -lerpHeight), Color.WHITE)
		
		prevHz = hz

func SetLine(value : bool) -> void:
	line = value

func SizeUpdate() -> void:
	flexOrigin = lineYOrigin * (size.y/1080)

func Paused() -> void:
	processing = false
	set_process(false)
	
	var division = size.x/(samples-1)
	lineObject.clear_points()
	for i in range(0,samples):
		lineObject.add_point(Vector2(division*i -6,0))

func Resumed() -> void:
	processing = true
	set_process(true)
