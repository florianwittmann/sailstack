.pragma library

var current_question = {};

var sites = [];
var sitesLoaded = false;

var choosedTags = [];

function isTagCurrentlyActive(tag) {
    var i = choosedTags.length;
    while (i--) {
       if (choosedTags[i] === tag) {
           return true;
       }
    }
    return false;
}

function addTag(tag) {
    choosedTags.push(tag)
}

function removeTag(tag) {
    var index = choosedTags.indexOf(tag);
    if (index > -1) {
        choosedTags.splice(index, 1);
    }
}

function removeAllTags() {
    choosedTags = [];
}

function getTagsString() {
    return choosedTags.join(";");
}
