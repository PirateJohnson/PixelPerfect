<?php
    //session_start();

	//
	header('Content-Type: image/jpeg');
	include('SimpleImage.php');

	while(1):

		//exec('/var/www/pixelpi/test.sh');
		$image = new SimpleImage();
		$image->load('face-color.jpg');
		$image->output(IMAGETYPE_JPEG);

	endwhile;
?>
