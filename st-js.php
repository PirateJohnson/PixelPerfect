<?php
    session_start();

    echo "<p> Test Stream </p>"
?>

<script type="text/javascript">
// Clock script server-time,   http://coursesweb.net

// use php to get the server time
var serverdate = new Date(<?php echo date('y,n,j,G,i,s'); ?>);

var ore = serverdate.getHours();       // hour
var minute = serverdate.getMinutes();     // minutes
var secunde = serverdate.getSeconds();     // seconds

// function that process and display data
function ceas() {
  secunde++;
  if (secunde>59) {
    secunde = 0;
    minute++;
  }
  if (minute>59) {
    minute = 0;
    ore++;
  }
  if (ore>23) {
    ore = 0;
  }

  var output = "<font size='4'><b><font size='1'>Server Time</font><br />"+ore+":"+minute+":"+secunde+"</b></font> <p></p>"

  document.getElementById("tag_ora").innerHTML = output;
}

// call the function when page is loaded and then at every second
window.onload = function(){
  setInterval("ceas()", 1000);
}
</script>
