$(document).ready(function(){
    var today = new Date();
    var birth = new Date("2001-04-24T00:00:00");

    var difference = Math.floor((today - birth) / (1000*60*60*24)/365)
    $(".age").html(difference);
});