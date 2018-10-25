var http = require("http");
var routers = ["192.168.0.1/","192.168.1.1/","192.168.1.90/","dribble.poison/"]
var fs = require('fs');
var index = fs.readFileSync("./www/index.html");
var jsob = fs.readdirSync('./www/js');
var repobj = {}

for (var i in jsob){
	// placing a / at the beginning is a bit of a lazy move
	repobj["/"+jsob[i]] = fs.readFileSync('./www/js/' + jsob[i]);
}

var server = http.createServer(function(request, response) {
	var url = request.headers.host + request.url;
	console.log('Request: ' + url);
	console.log("REQUEST URL" + request.url);
	console.log(request.headers);

	var headers = {
		"Content-Type": "text/html",
		"Server": "dribble",
		"Cache-Control": "public, max-age=99936000",
		"Expires": "Wed, 2 Nov 2050 10:00:00 GMT",
		"Last-Modified": "Wed, 15 Nov 1988 10:00:00 GMT",
		"Access-Control-Allow-Origin": "*"
	};

	// Cache the index page of the router
	if (routers.includes(url))
	{
		console.log("cache until the end of the world");
		response.writeHead(200, headers);
		response.write(index);
		response.end();
		return;
	}
	// cache the payload
	else if (repobj[request.url]){
		// cache javascript
		console.log("indexOf: " + url.indexOf(".js"));
		console.log("length: " + url.length);
		console.log("cache JS until the end of the world");
		headers["Content-Type"] = "application/javascript";
		response.writeHead(200, headers);
		response.write(repobj[request.url]);
		response.end();
		return;
	}
});

server.listen(80);
