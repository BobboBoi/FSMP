extends Node
class_name StreamLoader

static func LoadMP3FromBytes(bytes : PackedByteArray) -> AudioStreamMP3:
	var stream := AudioStreamMP3.new()
	stream.data = bytes
	stream.loop = false
	return stream

static func LoadOGGFromBytes(bytes : PackedByteArray) -> AudioStreamOggVorbis:
	var stream := AudioStreamOggVorbis.load_from_buffer(bytes)
	stream.loop = false
	return stream

static func LoadWAVFromBytes(bytes : PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.load_from_buffer(bytes)
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	return stream
