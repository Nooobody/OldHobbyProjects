DEFINE_BASECLASS("base_sa_object")

PORT_STATUS = {
	"Plug connected! No receiving socket found!",
	"Unplugged",
	"Awaiting transmission.",
	"Receiving resources!",
	"Transmiting resources!"
}

PORT_PLUGGED = 1
PORT_UNPLUGGED = 2
PORT_STANDBY = 3
PORT_INCOMING = 4
PORT_SENDING = 5