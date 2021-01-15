extends Control

const LINE_BREAK = "\n"

onready var id_text = $Main/Container/SideBar/GeneralContainer/IDName/IDText
onready var host_ip_address = $Main/Container/SideBar/HostJoinContainer/HostIP/HostIPText
onready var invalid_ip_label = $Main/Container/SideBar/HostJoinContainer/InvalidIPLabel
onready var invalid_name_label = $Main/Container/SideBar/GeneralContainer/InvalidName
onready var host_button = $Main/Container/SideBar/HostJoinContainer/HostButton
onready var join_button = $Main/Container/SideBar/HostJoinContainer/JoinButton
onready var begin_button = $Main/Container/SideBar/ButtonsContainer/BeginButton
onready var exit_button = $Main/Container/SideBar/ButtonsContainer/ExitButton
onready var log_text = $Main/Container/MainFrame/Container/LogContainer/LogLabel
onready var color_option = $Main/Container/SideBar/GeneralContainer/ColorPicker/ColorOption
onready var port_text = $Main/Container/SideBar/HostJoinContainer/HostPort/HostPortText
onready var invalid_port_label = $Main/Container/SideBar/HostJoinContainer/InvalidPort
onready var primary_option = $Main/Container/SideBar/ArmoryContainer/PrimaryOption
onready var secondary_option = $Main/Container/SideBar/ArmoryContainer/SecondaryOption
onready var credits_ui = $Credits

signal on_game_begin()

var is_begining = false
var is_showing_credits = false

func _ready():
	add_color_options()
	add_weapon_options()
	Network.connect("on_new_peer",self,"_on_player_connected")
	Network.connect("on_peer_disconnected",self,"_on_player_disconnected")
	Network.connect("on_server_disconnected",self,"_on_server_disconnected")
	Network.connect("on_cant_create_server",self,"_on_cant_create_server")
	Network.connect("on_server_created",self,"_on_server_created")
	Network.connect("on_connected_to_server",self,"_on_connected_to_server")
	connect("on_game_begin",Network,"_on_game_begin")
	get_tree().connect("connection_failed",self,"_on_connection_failed")

func _unhandled_input(event):
	if visible == true and event.is_action_pressed("escape"):
		if is_showing_credits:
			is_showing_credits = false
			return
		if !is_begining:
			get_tree().quit()

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
	primary_option.add_item("Assault Rifle",0)
	primary_option.add_item("Scout Rifle",1)
	primary_option.add_item("Pulse Rifle",2)
	primary_option.add_item("Sniper Rifle",3)
	primary_option.selected = 0
	Network.self_data.primary = primary_option.selected
	
	secondary_option.add_item("Pistol",0)
	secondary_option.add_item("SMG",1)
	secondary_option.selected = 0
	Network.self_data.secondary = secondary_option.selected

func reset():
	log_text.text = ""
	show()
	deactivate_hud(false)

remote func receive_log_text(text):
	append_log(text)

func buttons_disabled(value):
	host_button.disabled = value
	join_button.disabled = value

func deactivate_hud(value):
	id_text.editable = !value
	color_option.disabled = value
	primary_option.disabled = value
	secondary_option.disabled = value
	host_ip_address.editable = !value
	port_text.editable = !value
	host_button.disabled = value
	join_button.disabled = value
	begin_button.disabled = value
	exit_button.disabled = value

func append_log(text):
	log_text.append_bbcode(text + LINE_BREAK)

remotesync func begin_game():
	is_begining = true
	deactivate_hud(true)
	append_log("Starting the game...")
	if get_tree().is_network_server():
		emit_signal("on_game_begin")

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
	rpc("begin_game")

func _on_player_connected(peer_id):
		print(peer_id)
		var player_info = Network.get_player_info(peer_id).name + " (" + str(Network.get_player_info(peer_id).id) + ")"
		var text = ""
		if peer_id == 1:
			text = "%s is hosting the game." % player_info
		else:
			text = "%s has connected." % player_info
		append_log(text)

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
	append_log("You (" + str(Network.get_player_info(1).id) + ") " + "are hosting the game.")

func _on_connected_to_server():
	append_log("You (" + str(Network.self_data.id) + ") " + " are connected to the server.")

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

func _on_PrimaryOption_item_selected(index):
	Network.self_data.primary = index

func _on_SecondaryOption_item_selected(index):
	Network.self_data.secondary = index

func _on_CreditsButton_pressed():
	credits_ui.start_credits()
	is_showing_credits = true
