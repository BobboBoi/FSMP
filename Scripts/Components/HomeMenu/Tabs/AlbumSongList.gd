extends SongList

func _init() -> void:
	bookMarks = false

func SortItems(a,b) -> bool:
	if a is MusicSelection and b is MusicSelection:
		if a.data.disc != b.data.disc:
			return a.data.disc < b.data.disc
		return a.data.albumIndex < b.data.albumIndex
	return false
