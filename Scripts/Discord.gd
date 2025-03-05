extends Node

func _ready():
	discord_sdk.app_id = 1135292728712896563 #Don't you fucking dare
	print("Discord working: " + str(discord_sdk.get_is_discord_working()))
	refresh()

func refresh(track = null,album = null,artist = null):
	if track != null:
		if !discord_sdk.get_is_discord_working(): return
		discord_sdk.details = "Listening to: "+track
		discord_sdk.state = artist
		if artist != "" and artist != null and album != "" and album != null:
			discord_sdk.state += " - "
		elif (artist == null or artist == "") and (album == null or album == ""):
			discord_sdk.state += "I wonder what FSMP stands for...."
		discord_sdk.state += album
		discord_sdk.start_timestamp = int(Time.get_unix_time_from_system())
		
		discord_sdk.refresh()
		
		print("New status: "+track)
	else:
		discord_sdk.details = "Listening to: nothing... what a loser"
		discord_sdk.state = "I wonder what FSMP stands for...."
		
		discord_sdk.large_image = "disc"
		discord_sdk.large_image_text = "I wonder what FSMP stands for...."
		
		# "02:46 elapsed"
		# discord_sdk.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00 remaining"
		
		discord_sdk.refresh()
