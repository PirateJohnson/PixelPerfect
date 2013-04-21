<?php
   session_start();

	header('Content-Type: image/jpeg');
	include('SimpleImage.php');

	$lockfd = 0;
	$lock_file = '../sslard/.lockfile';
	$image_file = 'current-image.jpg';
	$error_str = "";
	$block = 1;

	while(1):

		// open the lock file for writing
		$lockfd = fopen( $lock_file, "w+" );

		// block and wait until an exclusive lock can be made
		if( flock( $lockfd, LOCK_EX, $block ) ) {
	
			// read the image while we have the lock
			$image = new SimpleImage();
        	$image->load( $image_file );
			// unlock
			flock( $lockfd, LOCK_UN );

			// display
			$image->output(IMAGETYPE_JPEG);
		} 
		else {
				$error_str = "Failed to place a lock on $lock_file\n";
				$image = new SimpleImage();
        		$image->load('face-color.jpg');
//				$image->load('current-image.jpg');
        		$image->output(IMAGETYPE_JPEG);
		}

		// close the file
		fclose( $lockfd );

		//$image = new SimpleImage();
		//$image->load('face-color.jpg');	
		//$image->output(IMAGETYPE_JPEG);


	endwhile;
?>
