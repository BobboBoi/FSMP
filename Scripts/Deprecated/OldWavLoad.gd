extends Node

func LoadWAVFromBytes(bytes : PackedByteArray) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = stream.FORMAT_16_BITS # Causes Issues for some files
	stream.stereo = true
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.data = bytes

	var meta : PackedByteArray = []
	meta.resize(356)
	var numb = bytes.size()-356
	
	for i in range(356):
		meta[i] += bytes[numb]
		#if i == 355: print(numb," ",bytes.size()-1)
		numb += 1
	
	#var metadata : String = "" #Gonna use a NUGET for this
	#for i in meta:
		#var arr : PackedByteArray = [i]
		#metadata += arr.get_string_from_utf8()
	#print(metadata)
	
	return stream
