$(document).ready(function() {
    $("input[name=search]").click(function() {
        $(this).val('');
    });
});

function toggleview(id1,id2) {
    var obj1 = document.getElementById(id1);
    var obj2 = document.getElementById(id2);
    (obj1.className=="itemshown") ? obj1.className="itemhidden" : obj1.className="itemshown"; 
    (obj1.className=="itemshown") ? obj2.innerHTML="<img border='0' src='images/red-open.gif' alt='[&ndash;]'>" : obj2.innerHTML="<img border='0' src='images/red-closed.gif' alt='[+]'>"; 
};

// Show the logs for the current module in the right
function show_logs() {
    var url = ''+window.parent.frames[1].location;
    var sl1 = url.indexOf('//');
    var mod = '';
    if (sl1 > 0) {
        var sl2 = url.indexOf('/', sl1+2);
        if (sl2 > 0) {
            var sl3 = url.indexOf('/', sl2+1);
            if (sl3 > 0) {
                mod = url.substring(sl2+1, sl3);
            } else {
                mod = url.substring(sl2+1);
            }
        }
    }
    if (mod && mod.indexOf('.cgi') <= 0 && mod !== 'webminlog') {
        // Show one module's logs
        window.parent.frames[1].location = 'webminlog/search.cgi?tall=4&uall=1&fall=1&mall=0&module='+mod;
    } else {
        // Show all logs
        window.parent.frames[1].location = 'webminlog/search.cgi?tall=4&uall=1&fall=1&mall=0&mall=1'
    }
};
