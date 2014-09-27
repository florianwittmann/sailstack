function prettyRichText(text, linkColor) {
    console.log("Pretty: " + text.replace("\n",""));
    return text
        .replace(/<pre>/gi,'<pre style="white-space: pre-wrap;">')
        .replace(/<pre /gi,'<pre style="white-space: pre-wrap;" ')
        .replace(/<code>/gi,'<code style="white-space: pre-wrap;">')
        .replace(/<code /gi,'<code style="white-space: pre-wrap;" ')
        .replace(/<img /gi,'<img style="width: 100%;" ')
        .replace(/<a /gi,'<a style="color:#ffffff" ');

}

function serialize(object, maxDepth) {
function _processObject(object, maxDepth, level) {
        var output = Array()
        var pad = "  "
        if (maxDepth == undefined) {
            maxDepth = -1
        }
        if (level == undefined) {
            level = 0
        }
        var padding = Array(level + 1).join(pad)

        output.push((Array.isArray(object) ? "[" : "{"))
        var fields = Array()
        for (var key in object) {
            var keyText = Array.isArray(object) ? "" : ("\"" + key + "\": ")
            if (typeof (object[key]) == "object" && key != "parent" && maxDepth != 0) {
                var res = _processObject(object[key], maxDepth > 0 ? maxDepth - 1 : -1, level + 1)
                fields.push(padding + pad + keyText + res)
            } else {
                fields.push(padding + pad + keyText + "\"" + object[key] + "\"")
            }
        }
        output.push(fields.join(",\n"))
        output.push(padding + (Array.isArray(object) ? "]" : "}"))

        return output.join("\n")
    }

    return _processObject(object, maxDepth)
}

function output(text) {
    var elements = text.split('\n');
    for(var i=0; i<elements.length; i++) {
        console.log(elements[i]);
    }
}



