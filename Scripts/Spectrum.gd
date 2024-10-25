extends Control

@onready var analyzer : AudioEffectSpectrumAnalyzerInstance
@onready var window : Window = get_window()
@onready var sprite := %Sprite #Will be removed in the future
@onready var lineObject := %Line

@onready var part = preload("res://Scenes/particles.tscn")

#@export var width : float = 750;
@export var samples := 320;
@export var height := 350;
@export var beatHeight := 0.6
@export var beatIndex := 10
@export var beatDiff := 0.05

@export var line = true
@export var lineYOrigin := 0.0
var flexOrigin := 0.0


const FREQ_MAX = 11050.0/3
const MIN_DB = 60 #80
const LERP : float = 0.4

var lastPos : Array
var lastBeat
var beat
var prevHz := 0.0

func _ready():
	if !resized.is_connected(SizeUpdate): resized.connect(SizeUpdate)
	analyzer = AudioServer.get_bus_effect_instance(1,0)
	flexOrigin = lineYOrigin
	
	lastPos.resize(samples)

func _process(_delta):
	if window.mode == window.Mode.MODE_MINIMIZED: return
	queue_redraw()

func _draw():
	var division = size.x/(samples-1)
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
		
		#Check if current index is the beat index
		if i == beatIndex and final > (height)*beatHeight:
			#if lastbeat is set check if for a valid beat
			if lastBeat != null and !beat:
				var dif = lastBeat - final
				if dif < 0:
					dif *= -1
					if dif > beatDiff*height:
						#print("Beat: ",dif)
						var particles = part.instantiate()
						particles.emitting = true
						sprite.add_child(particles)
						beat = true
						$Timer.start()
				elif beat:
					beat = false
			lastBeat = final
			
			sprite.scale = Vector2(lerp(sprite.scale.x, 1 + (final-(height)*beatHeight)/height*2 ,0.4) , \
			lerp(sprite.scale.y, 1 + (final-(height)*beatHeight)/height*2 ,0.4)) 
			if line:
				lineObject.add_point(Vector2(division*i -6,lerpHeight*-1 + flexOrigin))
			else:
				draw_rect(Rect2(division * i, size.y, division, -lerpHeight), Color.RED)
			
		else:
			if line:
				lineObject.add_point(Vector2(division*i -6,lerpHeight*-1 + flexOrigin))
			else:
				draw_rect(Rect2(division * i, size.y, division, -lerpHeight), Color.WHITE)
		
		#Beatindicator update
		if i == beatIndex and !final > (height)*beatHeight:
			sprite.scale = Vector2(lerp(sprite.scale.x, 1.0, 0.4), lerp(sprite.scale.y, 1.0,0.4)) 
		prevHz = hz

func SetLine(value : bool) -> void:
	line = value

func SizeUpdate() -> void:
	flexOrigin = lineYOrigin * (size.y/1080)

func CoolDownTimout() -> void:
	beat = false
