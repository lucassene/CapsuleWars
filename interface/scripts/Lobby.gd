extends Control

const LINE_BREAK = "\n"

onready var id_text = $Main/Container/SideBar/GeneralContainer/IDName/IDText
onready var host_ip_address = $Main/Container/SideBar/HostJoinContainer/HostIP/HostIPText
onready var invalid_ip_label = $Main/Container/SideBar/HostJoinContainer/InvalidIPLabel
onready var invalid_name_label = $Main/Container/SideBar/GeneralContainer/InvalidName
onready var host_button = $Main/Container/SideBar/HostJoinContainer/HostButton
onready var join_button = $Main/Container/SideBar/HostJoinContainer/JoinButton
onready var begin_button = $Main/Container/SideBar/ButtonsContainer/BeginButton
onready var log_text = $Main/Container/MainFrame/LogContainer/LogLabel
onready var color_option = $Main/Container/SideBar/GeneralContainer/ColorPicker/ColorOption
onready var port_text = $Main/Container/SideBar/HostJoinContainer/HostPort/HostPortText
onready var invalid_port_label = $Main/Container/SideBar/HostJoinContainer/InvalidPort
onready var weapon_option = $Main/Container/SideBar/ArmoryContainer/WeaponOption

signal on_game_begin()

func _ready():
	add_color_options()
	add_weapon_options()
	Network.connect("on_new_peer",self,"_on_player_connected")
	Network.connect("on_peer_disconnected",self,"_on_player_disconnected")
	Network.connect("on_server_disconnected",self,"_on_server_disconnected")
	Network.connect("on_cant_create_server",self,"_on_cant_create_server")
	Network.connect("on_server_created",self,"_on_server_created")
	connect("on_game_begin",Network,"_on_game_begin")
	get_tree().connect("connection_failed",self,"_on_connection_failed")

func add_color_options():
	color_option.add_item("Black",0)
	color_option.add_item("Blue",1)
	color_option.add_item("Gray",2)
	color_option.add_item("Green",3)
	color_option.add_item("Pink",4)
	color_option.add_item("Red",5)
	color_option.add_item("White",6)
	color_option.add_item("Yellow",7)
	randomize()
	color_option.selected = randi()%7
	Network.self_data.color = Global.colors[color_option.selected]

func add_weapon_options():
	weapon_option.add_item("Assault Rifle",0)
	weapon_option.add_item("Scout Rifle",1)
	weapon_option.add_item("Pulse Rifle",2)
	weapon_option.add_item("Sniper Rifle",3)
	weapon_option.selected = 0
	Network.self_data.primary = weapon_option.selected

func reset():
	log_text.text = ""
	show()
	buttons_disabled(false)
	begin_button.disabled = true

remote func receive_log_text(text):
	append_log(text)

func buttons_disabled(value):
	host_button.disabled = value
	join_button.disabled = value

func append_log(text):
	log_text.append_bbcode(text + LINE_BREAK)

func _on_HostButton_pressed():
	var can_join = true
	var port = Network.DEFAULT_PORT
	if !port_text.text.empty() and !port_text.text.is_valid_integer():
		can_join = false
		invalid_port_label.show()
	else:
		port = port_text.text
	if id_text.text.empty():
		can_join = false
		invalid_name_label.show()
	if can_join:
		if port.empty(): port = Network.DEFAULT_PORT
		Network.create_server(id_text.text,port)

func _on_JoinButton_pressed():
	var can_join = true
	var ip = Network.DEFAULT_IP
	var port = Network.DEFAULT_PORT
	if id_text.text.empty():
		can_join = false
		invalid_name_label.show()
	if !host_ip_address.text.empty() and !host_ip_address.text.is_valid_ip_address():
		can_join = false
		invalid_ip_label.show()
	else:
		ip = host_ip_address.text
	if !port_text.text.empty() and !port_text.text.is_valid_integer():
		can_join = false
		invalid_port_label.show()
	else:
		port = port_text.text
	if can_join:
		if ip.empty(): ip = Network.DEFAULT_IP
		if port.empty(): port = Network.DEFAULT_PORT
		Network.create_client(id_text.text,ip,port)
		buttons_disabled(true)
		append_log("Connecting to the host...")

func _on_BeginButton_pressed():
	append_log("Beginning the game...")
	emit_signal("on_game_begin")

func _on_player_connected(id):
	if get_tree().is_network_server():
		append_log(Network.get_player_info(id).name + " (" + str(Network.get_player_info(id).id) + ") " + "has connected.")
		rpc_id(id,"receive_log_text",log_text.text)

func _on_player_disconnected(player):
	append_log(player.name + " has disconnected.")
	
func _on_connection_failed():
	append_log("Cannot connect to the server.")
	buttons_disabled(false)
	begin_button.disabled = true

func _on_server_disconnected():
	log_text.bbcode_text = "Connection to the server lost." + LINE_BREAK
	show()
	buttons_disabled(false)
	begin_button.disabled = true

func _on_server_created():
	buttons_disabled(true)
	begin_button.disabled = false
	append_log(Network.get_player_info(1).name + " (" + str(Network.get_player_info(1).id) + ") " + "is hosting the game.")

func _on_cant_create_server(error):
	match error:
		ERR_CANT_CREATE:
			append_log("Error creating the server.")
		ERR_ALREADY_IN_USE:
			append_log("You already have a running server.")
	reset()

func _on_IDText_text_changed(_new_text):
	invalid_name_label.hide()

func _on_ColorOption_item_selected(index):
	Network.self_data.color = Global.colors[index]

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_WeaponOption_item_selected(index):
	Network.self_data.primary = index
