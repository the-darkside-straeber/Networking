extends Control

func setVisuals(pName : String, n : int, text: String) -> void:
	$Label.text = pName
	$Portrait.frame = n
	$Score.text = text
