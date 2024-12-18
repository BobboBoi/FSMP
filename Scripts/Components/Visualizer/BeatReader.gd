extends Control
class_name BeatReader

@onready var analyzer : AudioEffectSpectrumAnalyzerInstance
@onready var window : Window = get_window()

@export var debug := false
@export var samples := 320
@export var height := 350
@export var beatHeight := 0.5
@export var beatStart := 0
@export var beatEnd := 5
@export var beatDiff := 0.1

const FREQ_MAX = 11050.0/2
const MIN_DB = 45 #80
const LERP : float = 0.4

var lastBeat := 0.0
var beat := false

signal Beat(energy : float)
signal Update(mod : float)

func _ready():
	analyzer = AudioServer.get_bus_effect_instance(1,0)

func _process(_delta):
	if window.mode == window.Mode.MODE_MINIMIZED: return
	queue_redraw()

func _draw():
	var division = size.x/(samples)
	var prevHz := 0.0
	var final := 0.0
	
	for i in range(beatStart,beatEnd):
		var hz = i * (FREQ_MAX / samples)
		
		#Gets the frequency at the position hz
		var magnitude: float = analyzer.get_magnitude_for_frequency_range(prevHz, hz,AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX).length()
		
		var energy = clamp((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		final += energy*height
		
		prevHz = hz
	
	final /= beatEnd-beatStart
	
	var emitted := false
	
	if final > height*beatHeight:
		var dif = final - lastBeat
		var rawDif = dif
		dif = dif if dif > 0 else -dif
		
		if beat:
			if dif < beatDiff*height:
				beat = false
		elif dif > beatDiff*height and rawDif > 0:
			Beat.emit(final)
			if debug:
				draw_rect(Rect2(division * beatEnd, size.y, division, -final), Color.RED)
				emitted = true
			#print(dif," | ",beatDiff*height)
			beat = true
	
	if !emitted and debug:
		draw_rect(Rect2(division * beatEnd, size.y, division, -final), Color.WHITE)
	
	lastBeat = final
	Update.emit(final/(height))
