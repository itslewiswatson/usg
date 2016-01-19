NAME_MINIMUM_LENGTH = 4

permissions = {
	invite = "Invite members", ranks = "Promote/demote and kick", 
	withdraw = "Withdraw from group bank", updateInfo = "Update the group info",
	customRanks = "Edit custom ranks", setColor = "Set the group color"
}

defaultRanks = { -- the default 6 ranks
	{ name = "Trial", permissions = {}}, { name = "Member", permissions = {}}, 
	{ name = "Staff", permissions = {invite = true, updateInfo = true}}, { name = "Leading staff", permissions = { invite = true, ranks = true, updateInfo = true }},
	{ name = "Leader", permissions = {invite = true, ranks = true, withdraw = true, updateInfo = true}},
	{ name = "Founder", permissions = {all = true}} -- same as Leader, but can demote/kick/promote to Leaders and delete the group
}
