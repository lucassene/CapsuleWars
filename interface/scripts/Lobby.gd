extends Control

const LINE_BREAK = "\n"

onready var id_text = $Main/Container/SideBar/IDName/IDText
onready var host_ip_address = $Main/Container/SideBar/HostIP/HostIPText
onready var invalid_ip_label = $Main/Container/SideBar/InvalidIPLabel
onready var invalid_name_label = $Main/Container/SideBar/InvalidName
onready var host_button = $Main/Container/SideBar/HostButton
onready var join_button = $Main/Container/SideBar/JoinButton
onready var begin_button = $Main/Container/SideBar/BeginButton
onready var log_text = $Main/Container/MainFrame/LogContainer/LogLabel
onready var color_option = $Main/Container/SideBar/ColorPicker/ColorOption

var selected_color = 0

signal on_game_begin()

func _ready():
	add_color_options()
	Network.connect("on_new_peer",self,"_on_player_connected")
	Network.connect("on_peer_disconnected",self,"_on_player_disconnected")
	Network.connect("on_server_disconnected",self,"_on_server_disconnected")
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
	Network.self_data.color = Network.colors[color_option.selected]
	selected_color = color_option.selected

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
	if !id_text.text.empty():
		Network.create_server(id_text.text)
		buttons_disabled(true)
		begin_button.disabled = false
		append_log(Network.get_player_info(1).name + " (" + str(Network.get_player_info(1).id) + ") " + "is hosting the game.")
	else:
		invalid_name_label.show()

func _on_JoinButton_pressed():
	if !id_text.text.empty():
		if host_ip_address.text.empty():
			Network.create_client(id_text.text)
			buttons_disabled(true)
			append_log("Connecting to the host...")
		elif host_ip_address.text.is_valid_ip_address():
			invalid_ip_label.hide()
			Network.create_client(id_text.text,host_ip_address.text)
			buttons_disabled(true)
			append_log("Connecting to the host...")
		else:
			invalid_ip_label.show()
	else:
		invalid_name_label.show()

func _on_BeginButton_pressed():
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
	reset()

func _on_IDText_text_changed(_new_text):
	invalid_name_label.hide()

func _on_ColorOption_item_selected(index):
	selected_color = index
	Network.self_data.color = Network.colors[index]
