extends Node
class_name StreamLoader

static func LoadMP3FromPath(path : String) -> AudioStreamMP3:
	var stream := AudioStreamMP3.load_from_file(path)
	stream.loop = false
	return stream

static func LoadOGGFromPath(path : String) -> AudioStreamOggVorbis:
	var stream := AudioStreamOggVorbis.load_from_file(path)
	stream.loop = false
	return stream

static func LoadWAVFromPath(path : String) -> AudioStreamWAV:
	return AudioStreamWAV.load_from_file(path, {&"loop_mode": AudioStreamWAV.LOOP_DISABLED})

static func LoadFLACFromPath(path : String) -> AudioStreamFLAC:
	var stream := AudioStreamFLAC.load_from_file(path)
	stream.loop = false
	return stream
