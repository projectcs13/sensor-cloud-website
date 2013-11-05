//Needs machine ip + port and type.
//var HOST = "localhost"
var HOST = "srv1.csproj13.student.it.uu.se"
var PORT = 8080

var socket = null;
var url = window.location.href.split("/");
var stream_id = url[url.length - 1];

function toggle(value) {
    if(value)
        connect();
    else
        disconnect();
}

function connect() {
    // Connect for the first time, create a socket
    if(socket == null) {
    var connect = function (ns) {
        return io.connect(ns, {
            query: 'ns='+ns,
            resource: "socket.io"
        });
    }
    console.log(stream_id);
        socket = connect('http://' + HOST + ':' + PORT + '/streams.'+stream_id);
        socket.on('message', function(data) {
            graph_object.add_single_datapoint(data);
            console.log(data);
        });
    }else {
        socket.socket.reconnect();
    }

}

function disconnect() {
    socket.socket.disconnect();

}
