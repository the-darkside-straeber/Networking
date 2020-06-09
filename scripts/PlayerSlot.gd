extends Control

func setVisuals(pName : String, text: String, character: int, color: int) -> void:
	$Label.text = pName
	$Potrait.texture = Match.get_sprite(character, color)
	$Score.text = text
