extends Control


func join():
	Network.self_data.pName = $"NameEdit".text
	if Network.self_data.pName == "":
		Network.self_data.pName = "fiish"
	var ip = $IPEdit.text
	if ip == "":
		ip = "127.0.0.1"
	if ip.is_valid_ip_address():
		Network.JoinServer(ip)

func create():
	Network.self_data.pName = $"NameEdit".text
	if Network.self_data.pName == "":
		Network.self_data.pName = "fiish"
	Network.CreateServer()
