extends Node

func _ready():
	refresh()

func refresh(track = null,album = null):
	if(track != null):
		discord_sdk.state = "Listening to: "+track+("("+album+")" if album != "" else "")
		discord_sdk.start_timestamp = int(Time.get_unix_time_from_system())
		
		discord_sdk.refresh()
		
		print("Status"+track)
	else:
		discord_sdk.app_id = 1135292728712896563 #Don't you fucking dare
		print("Discord working: " + str(discord_sdk.get_is_discord_working()))
		
		discord_sdk.details = "I wonder what FSMP stands for...."
		discord_sdk.state = "Listening to: nothing... what a loser"
		
		discord_sdk.large_image = "disc"
		discord_sdk.large_image_text = "LOOK GUYS! its an idiot"
		
		# "02:46 elapsed"
		# discord_sdk.end_timestamp = int(Time.get_unix_time_from_system()) + 3600 # +1 hour in unix time / "01:00 remaining"
		
		discord_sdk.refresh()
