extends Node2D

func Pressed():
	Network.rpc("GameSetup")
