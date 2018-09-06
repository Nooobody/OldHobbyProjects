DEFINE_BASECLASS("base_wire_entity")

S_STATUS = 1
S_TEMPERATURE = 2
S_NODE = 3
S_STORAGE = 4
S_PORT = 5
S_CONNECTEDPORT = 6
S_NODERESOURCE = 7
S_INPUTS = 8
S_OUTPUTS = 9
S_COVERAGE = 10
S_PERCENT = 11

S_ENTDATA = {
	S_STATUS = {
		type = "Bit",
		name = "Status"
	},
	S_TEMPERATURE = {
		type = "Float",
		name = "Temperature"
	},
	S_NODE = {
		type = "A_Node",
		name = "Links"
	},
	S_STORAGE = {
		type = "A_Res",
		name = "Storage"
	},
	S_PORT = {
		type = "UInt_4",
		name = "Status"
	},
	S_CONNECTEDPORT = {
		type = "UInt_16",
		name = "ConnectedSocket"
	},
	S_NODERESOURCE = {
		type = "A_NodeRes",
		name = "NodeRes"
	},
	S_INPUTS = {
		type = "A_Res",
		name = "RInputs"
	},
	S_OUTPUTS = {
		type = "A_Res",
		name = "ROutputs"
	},
	S_COVERAGE = {
		type = "UInt_8",
		name = "Coverage"
	},
	S_PERCENT = {
		type = "UInt_8",
		name = "Percent"
	}
}