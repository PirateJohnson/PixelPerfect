<?php
	session_start();
	
	echo "<p> Test Stream </p>"
?>

<script type="text/javascript" language="JavaScript"> 
	newImage = new Image();

	function LoadNewImage()
	{
		var unique = new Date();
		document.images.webcam.src = newImage.src;
		newImage.src = "https://pixelpi/image_res/image-stream.php?time=" + unique.getTime();
		}

	function InitialImage()
	{
		var unique = new Date();
		newImage.onload = LoadNewImage;
		newImage.src = "https://pixelpi/image_res/image-stream.php?time=" + unique.getTime();
		document.images.webcam.onload="";
	}
</script>

<img src="https://pixelpi/image_res/image-stream.php" name="test stream" onload="InitialImage()" width="300" height="250">
