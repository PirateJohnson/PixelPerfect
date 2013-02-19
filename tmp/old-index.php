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
		echo "Current Server Time: " . $current_date;

		// include the main action/command set form
		include 'forms/main-action.html'
		
		//phpinfo();

		//echo "<img src='image.php' title='Test' alt='Test' />";
	?> 
	<!--
	<form><input type="button" value="Test Face Detection" onClick="window.location.href='index.php'"></form> 

	<form><input type="button" value="Test Face Detection with OpenCV" onClick="window.location.href='index.php'"></form> 
	-->
	</body>
</html>
