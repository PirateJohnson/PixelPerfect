<?php
	session_start();
?>

<html>
	<head>
		<title>PixelPi Command Viewer</title>
	</head>
	<body>

	<?php

		// include the system resources
		include 'sys_res/system.php';
	
		// print the title
		echo '<p>PixelPi Command Viewer</p>';
		
		// print the server time
		// should use javascript to update
		echo "<p>Current Server Time: " . $current_date . "</p>";

		// include the main action/command set form
		include 'forms/main-action.html';
		
		// check the buttons
		// TODO - not sure if this is the best method as I see errors in the error log...
		$edit_button = $_POST['edit_registers_b'];
		if( isset( $edit_button ) )
		{
			header( 'Location: https://pixelpi/hw_interface/edit_registers.php' );
		}
		$view_button = $_POST['view_cur_registers_b'];
		if( isset( $view_button ) )
		{
			header( 'Location: https://pixelpi/hw_interface/view_registers.php' );
		}
	?> 
		
	</body>
</html>
