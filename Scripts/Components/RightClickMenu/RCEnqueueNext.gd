extends EnqueueNextButton

func Show(_src : Node) -> void:
	if home.selected.size() <= 0: return
	show()
