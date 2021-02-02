extends Control

const LINE_BREAK = "\n"

onready var id_text = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/IDName/IDText
onready var host_ip_address = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/HostIP/HostIPText
onready var invalid_ip_label = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/InvalidIPLabel
onready var invalid_name_label = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/InvalidName
onready var host_button = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/HostButton
onready var join_button = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/JoinButton
onready var begin_button = $MainContainer/VBoxContainer/MenuContainer/FinalContainer/BeginButton
onready var exit_button = $MainContainer/VBoxContainer/LogContainer/LogContainer/CreditsContainer/ExitButton
onready var log_text = $MainContainer/VBoxContainer/LogContainer/LogContainer/LogLabel
onready var color_option = $MainContainer/VBoxContainer/MenuContainer/LooksContainer/ColorPicker/ColorOption
onready var port_text = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/HostPort/HostPortText
onready var invalid_port_label = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/InvalidPort
onready var primary_option = $MainContainer/VBoxContainer/MenuContainer/LoadoutContainer/PrimaryOption
onready var secondary_option = $MainContainer/VBoxContainer/MenuContainer/LoadoutContainer/SecondaryOption
onready var credits_ui = $Credits
onready var type_container = $MainContainer/VBoxContainer/MenuContainer/TypeContainer
onready var type_separator = $MainContainer/VBoxContainer/MenuContainer/TypeSeparator
onready var looks_container = $MainContainer/VBoxContainer/MenuContainer/LooksContainer
onready var looks_separator = $MainContainer/VBoxContainer/MenuContainer/LooksSeparator
onready var loadout_container = $MainContainer/VBoxContainer/MenuContainer/LoadoutContainer
onready var loadout_separator = $MainContainer/VBoxContainer/MenuContainer/LoadoutSeparator
onready var final_container = $MainContainer/VBoxContainer/MenuContainer/FinalContainer
onready var final_separator = $MainContainer/VBoxContainer/MenuContainer/FinalSeparator
onready var type_label = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/TypeLabel
onready var host_ip_container = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/HostIP
onready var upnp_button = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/UpnpButton
onready var ready_button = $MainContainer/VBoxContainer/MenuContainer/FinalContainer/ReadyButton
onready var cancel_button = $MainContainer/VBoxContainer/MenuContainer/TypeContainer/CancelButton
onready var new_container = $MainContainer/VBoxContainer/MenuContainer/NewContainer

signal on_game_begin()

var is_begining = false
var is_showing_credits = false
var ready_players = []
var is_player_ready = false
var has_game = false

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
	show()
	deactivate_hud(false)
	hide_containers(true)

func hide_containers(value):
	new_container.visible = value
	type_separator.visible = !value
	type_container.visible = !value
	looks_separator.visible = !value
	looks_container.visible = !value
	loadout_separator.visible = !value
	loadout_container.visible = !value
	final_separator.visible = !value
	final_container.visible = !value

remote func receive_log_text(text):
	append_log(text)

func buttons_disabled(value):
	id_text.editable = !value
	port_text.editable = !value
	host_ip_address.editable = !value
	host_button.disabled = value
	join_button.disabled = value
	upnp_button.disabled = value

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

func show_character_options(is_server):
	if is_server:
		begin_button.show()
		begin_button.text = "Begin"
		ready_button.hide()
	else:
		ready_button.show()
		begin_button.hide()
	looks_separator.show()
	looks_container.show()
	loadout_separator.show()
	loadout_container.show()
	final_separator.show()
	final_container.show()

func show_type_options(is_host):
	buttons_disabled(false)
	new_container.hide()
	#type_separator.show()
	type_container.show()
	looks_separator.hide()
	looks_container.hide()
	loadout_separator.hide()
	loadout_container.hide()
	final_separator.hide()
	final_container.hide()
	if is_host:
		type_label.text = "Host a game"
	else:
		type_label.text = "Join a game"
	host_ip_container.visible = !is_host
	upnp_button.visible = is_host
	join_button.visible = !is_host
	host_button.visible = is_host

remotesync func client_ready(id,is_ready):
	var string
	if id == Network.self_data.id:
		string = "You are "
	else:
		string = Network.connected_players[id].name + " is "
	if is_ready:
		ready_players.append(id)
		string = string + "ready."
	else:
		ready_players.erase(id)
		string = string + "no longer ready."
	is_all_players_ready()
	append_log(string)

func is_all_players_ready():
	if ready_players.size() == Network.connected_players.size() - 1:
		begin_button.disabled = false
		begin_button.text = "Begin"
	else:
		begin_button.disabled = true
		begin_button.text = "Waiting players"

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
		host_button.pressed = false
		append_log("Creating the server...")
		yield(get_tree().create_timer(0.1),"timeout")
		Network.create_server(id_text.text,port,upnp_button.pressed)
		has_game = true

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
		join_button.text = "Joining"
		has_game = true
		append_log("Connecting to the host...")

func _on_BeginButton_pressed():
	rpc("begin_game")

func _on_player_connected(peer_id):
		print(str(peer_id) + " has connected")
		var player_info = Network.get_player_info(peer_id).name
		var text = ""
		if peer_id == 1:
			text = "%s is hosting the game." % player_info
		else:
			text = "%s has connected." % player_info
			if get_tree().is_network_server():
				begin_button.disabled = true
				begin_button.text = "Waiting players"
		append_log(text)

func _on_player_disconnected(player):
	ready_players.erase(player.id)
	is_all_players_ready()
	append_log(player.name + " has disconnected.")
	
func _on_connection_failed():
	append_log("Cannot connect to the server.")
	buttons_disabled(false)
	begin_button.disabled = true

func _on_server_disconnected():
	log_text.bbcode_text = "Connection to the server lost." + LINE_BREAK
	has_game = false
	reset()
	show()
	buttons_disabled(false)
	begin_button.disabled = true

func _on_server_created():
	buttons_disabled(true)
	host_button.text = "Hosting"
	show_character_options(true)
	append_log("You are hosting the game.")

func _on_connected_to_server():
	join_button.text = "Joined"
	append_log("You are connected to the server.")
	show_character_options(false)

func _on_cant_create_server(error):
	match error:
		UPNP.UPNP_RESULT_NO_GATEWAY:
			append_log("No UPnP device found. No server has been created.")
		_:
			append_log("(Error: " + str(error) + ") Cannot create a server.")
	deactivate_hud(false)

func _on_IDText_text_changed(_new_text):
	invalid_name_label.hide()

func _on_ColorOption_item_selected(index):
	Network.self_data.color = Global.colors[index]
	Network.send_info_to_server()

func _on_ExitButton_pressed():
	get_tree().quit()

func _on_PrimaryOption_item_selected(index):
	Network.self_data.primary = index
	Network.send_info_to_server()

func _on_SecondaryOption_item_selected(index):
	Network.self_data.secondary = index
	Network.send_info_to_server()

func _on_CreditsButton_pressed():
	credits_ui.start_credits()
	is_showing_credits = true

func _on_HostAGameButton_pressed():
	show_type_options(true)

func _on_JoinAGameButton_pressed():
	show_type_options(false)

func _on_ReadyButton_pressed():
	is_player_ready = !is_player_ready
	color_option.disabled = is_player_ready
	primary_option.disabled = is_player_ready
	secondary_option.disabled = is_player_ready
	if is_player_ready:
		ready_button.text = "Cancel"
	else:
		ready_button.text = "Ready"
	rpc("client_ready",Network.self_data.id,is_player_ready)

func _on_CancelButton_pressed():
	if has_game:
		append_log("Game cancelled.")
		has_game = false
		if get_tree().is_network_server():
			cancel_button.pressed = false
			append_log("Closing the server...")
			yield(get_tree().create_timer(0.1),"timeout")
			Network.clear_mapped_ports()
			append_log("Server terminated.")
	hide_containers(true)
	get_tree().network_peer = null

func _on_exit_to_lobby():
	log_text.bbcode_text = ""
	has_game = false
	reset()
	show()
	buttons_disabled(false)
