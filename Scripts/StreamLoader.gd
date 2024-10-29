extends Node
class_name StreamLoader

func LoadMP3FromBytes(bytes : PackedByteArray) -> AudioStreamMP3:
	var stream := AudioStreamMP3.new()
	stream.data = bytes
	stream.loop = true
	return stream

func LoadOGGFromBytes(bytes : PackedByteArray) -> AudioStreamOggVorbis:
	var stream := AudioStreamOggVorbis.load_from_buffer(bytes)
	stream.loop = true
	return stream

##Based on https://github.com/Stoxis/GDScriptAudioImport-Godot4/tree/master
func LoadWAVFromBytes(bytes : PackedByteArray) -> AudioStreamWAV:
	var newstream = AudioStreamWAV.new()
	var bits_per_sample = 0
	
	for i in range(0, 100):
		var those4bytes = str(char(bytes[i])+char(bytes[i+1])+char(bytes[i+2])+char(bytes[i+3]))
		
		if those4bytes == "fmt ":
			#using formatsubchunk index so it's easier to understand what's going on
			var fsc0 = i+8 #fsc0 is byte 8 after start of "fmt "
			
			#get format code [Bytes 0-1]
			var format_code = bytes[fsc0] + (bytes[fsc0+1] << 8)
			#var format_name
			#if format_code == 0: format_name = "8_BITS"
			#elif format_code == 1: format_name = "16_BITS"
			#elif format_code == 2: format_name = "IMA_ADPCM"
			#else: 
				#format_name = "UNKNOWN (trying to interpret as 16_BITS)"
				#format_code = 1
			
			#assign format to our AudioStreamSample
			newstream.format = format_code
			
			#get channel num [Bytes 2-3]
			var channel_num = bytes[fsc0+2] + (bytes[fsc0+3] << 8)
			#set our AudioStreamSample to stereo if needed
			if channel_num == 2: newstream.stereo = true
			
			#get sample rate [Bytes 4-7]
			var sample_rate = bytes[fsc0+4] + (bytes[fsc0+5] << 8) + (bytes[fsc0+6] << 16) + (bytes[fsc0+7] << 24)
			#set our AudioStreamSample mixrate
			newstream.mix_rate = sample_rate
			
			#aaaand bits per sample/bitrate [Bytes 14-15]
			bits_per_sample = bytes[fsc0+14] + (bytes[fsc0+15] << 8)
		
		if those4bytes == "data":
			assert(bits_per_sample != 0)
			
			var audio_data_size = bytes[i+4] + (bytes[i+5] << 8) + (bytes[i+6] << 16) + (bytes[i+7] << 24)
			var data_entry_point = (i+8)
			var data = bytes.slice(data_entry_point, data_entry_point + audio_data_size)
			
			if bits_per_sample in [24, 32]:
				newstream.data = convert_to_16bit(data, bits_per_sample)
			else:
				newstream.data = data
	
	#Calculate the size of each sample based on bits_per_sample
	@warning_ignore("integer_division")
	var sample_size = bits_per_sample / 8
	#get samples and set loop end
	var samplenum = newstream.data.size() / sample_size
	newstream.loop_end = samplenum
	newstream.loop_begin = 0
	
	#Disabled loop because loop forward does not work when imported
	#Disabled loop enablese the use of the finished function
	newstream.loop_mode = AudioStreamWAV.LOOP_DISABLED 
	return newstream

@warning_ignore("integer_division","narrowing_conversion")
func convert_to_16bit(data: PackedByteArray, from: int) -> PackedByteArray:
	print("converting to 16-bit from %d" % from)
	var time = Time.get_ticks_msec()
	if from == 24:
		var j = 0
		for i in range(0, data.size(), 3):
			data[j] = data[i+1]
			data[j+1] = data[i+2]
			j += 2
		data.resize(data.size() * 2/ 3)
	
	if from == 32:
		var spb := StreamPeerBuffer.new()
		var single_float: float
		var value: int
		for i in range(0, data.size(), 4):
			var sub_array = data.slice(i, i+4)
			spb.data_array = PackedByteArray(sub_array)
			single_float = spb.get_float()
			value = single_float * 32768
			data[i/2] = value
			data[i/2+1] = value >> 8
		data.resize(data.size() / 2)
	
	print("Took %f seconds for slow conversion" % ((Time.get_ticks_msec() - time) / 1000.0))
	return data
