.pragma library

var BASE="https://api.stackexchange.com"
var access_token = "";
var key = "0WNLVg7)hEYWHli57EKDqA((";
var site = "stackoverflow"
var siteName = "Stack Overflow"
var siteUrl = "http://stackoverflow.com"

function request(verb, endpoint, obj, cb) {
    print('request: ' + verb + ' ' + BASE + (endpoint? endpoint:''))
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if(xhr.readyState === XMLHttpRequest.DONE) {
            if(cb) {
                var res = JSON.parse(xhr.responseText.toString())
                cb(res);
            }
        }
    }
    xhr.open(verb, BASE + (endpoint? endpoint:''));
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.setRequestHeader('Accept', 'application/json');
    var data = obj?JSON.stringify(obj):''
    xhr.send(data)
}

function get_Sites(pageNr, cb) {
    request('GET', '/2.2/sites?page=' + pageNr + "&key=" +key + "&access_token="+access_token, null, cb)
}

function get_Questions(site,pageNr,sort,tagged,cb) {
    request('GET', '/2.2/questions?order=desc&sort=' + sort + '&tagged=' + escape(tagged) + '&site=' + site + '&page=' + pageNr + "&key=" +key + "&access_token="+access_token, null, cb)
}

function search_Questions(site,pageNr,sort,tagged,intitle,cb) {
    request('GET', '/2.2/search?order=desc&sort=' + sort.replace("hot","relevance") + '&tagged=' + escape(tagged) + '&intitle=' + intitle + '&site=' + site + '&page=' + pageNr + "&key=" +key + "&access_token="+access_token, null, cb)
}

function get_Question(site,question_id, cb) {
    request('GET', '/2.2/questions/' + question_id + '?site=' + site + '&filter=withbody&key=' +key + "&access_token="+access_token, null, cb)
}

function get_Answers(site,question_id, cb) {
    request('GET', '/2.2/questions/' + question_id + '/answers?site=' + site + '&filter=withbody&sort=votes&key=' +key + "&access_token="+access_token, null, cb)
}

function get_CommentsForQuestion(site,question_id, cb) {
    request('GET', '/2.2/questions/' + question_id + '/comments?site=' + site + '&filter=withbody&key=' +key + "&access_token="+access_token, null, cb)
}

function get_CommentsForAnswer(site,answer_id, cb) {
    request('GET', '/2.2/answers/' + answer_id + '/comments?site=' + site + '&filter=withbody&key=' +key + "&access_token="+access_token, null, cb)
}

function get_Tags(site,pageNr,inname,cb) {
    request('GET', '/2.2/tags?order=desc&sort=popular&inname=' + escape(inname.toLowerCase()) + '&site=' + site + '&page=' + pageNr + "&key=" +key + "&access_token="+access_token, null, cb)
}

function invalidate_Token(token, cb) {
    request('GET', '/2.2/access-tokens/' + token + '/invalidate?key=' + key, null, cb);


}
