extends Control

@onready var analyzer : AudioEffectSpectrumAnalyzerInstance
@onready var window : Window = get_window()
@onready var lineObject := %Line

#@export var width : float = 750;
@export var freqCurve : Curve
@export var heightCurve : Curve
@export var samples := 320;
@export var height := 400;
@export var spectrumBoost := false

@export var line = true
@export var lineYOrigin := 0.0
var flexOrigin := 0.0
var fheight := 400;


@export var MIN_DB = 50 #80
const FREQ_MAX = 11050.0
const LERP := 0.5

var lastPos : Array
var processing := true

func _ready():
	if !window.size_changed.is_connected(SizeUpdate): window.size_changed.connect(SizeUpdate)
	if !Player.Paused.is_connected(Paused): Player.Paused.connect(Paused)
	if !Player.Resumed.is_connected(Resumed): Player.Resumed.connect(Resumed)
	
	analyzer = AudioServer.get_bus_effect_instance(1,0)
	flexOrigin = lineYOrigin
	
	lastPos.resize(samples)

func _process(_delta):
	if window.mode == window.Mode.MODE_MINIMIZED: return
	queue_redraw()

func _draw():
	if !processing: return
	var division = size.x/(samples-1)
	var prevHz := 0.
	var mindb := float(MIN_DB + 10*int(spectrumBoost))
	
	lineObject.clear_points()
	lineObject.position.x = division
	for i in range(0,samples+1):
		var p := freqCurve.sample(float(i) / samples)
		var hz = p * FREQ_MAX
		
		#Gets the frequency at the positin hz
		var magnitude := analyzer.get_magnitude_for_frequency_range(prevHz, hz).length()
		
		#Turn magnitude to decibels and set max and min values between 0 and 1
		#MIN_DB + linear_to_db(magnitude)) / MIN_DB is the value clamp just limits it
		var boost := 1+(int(spectrumBoost)*0.4)
		var energy = clamp(((mindb + linear_to_db(magnitude)) / mindb) * boost, 0, 1) 
		
		#Calculate height
		var final = energy*fheight
		var lerpHeight : float
		if lastPos[i-1] != null:
			lerpHeight = lerp(final as float ,lastPos[i-1] as float, LERP)
		else:
			lerpHeight = final
		lastPos[i-1] = float(lerpHeight)
		lerpHeight *= heightCurve.sample(float(i) / samples)
		
		if line:
			lineObject.add_point(Vector2(division*i -6,lerpHeight*-1 + flexOrigin))
		else:
			draw_rect(Rect2(division * i, size.y, division, -lerpHeight), Color.WHITE)
		
		prevHz = hz

func SetBoost(value : bool) -> void:
	spectrumBoost = value

func SetLine(value : bool) -> void:
	line = value

func SizeUpdate() -> void:
	flexOrigin = lineYOrigin * (size.y/1080)
	
	if window == null: return
	@warning_ignore("narrowing_conversion")
	fheight = float(height)*(float(window.size.y)/648)

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
