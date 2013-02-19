<?php
	session_start();
?>

<html>
	<head>
		<title>PixelPi Edit Registers</title>
	</head>
	<body>

	<?php
	
		require_once 'Config/Lite.php';
		
		$default_config_file = 'default-register-values.ini';
	
		// print the title
		echo '<p>Edit Registers</p>';

		$default_config = new Config_Lite( 'default-register-values.ini' );
		
		echo $default_config->get( 'meta', 'filename' ) . "<br>";
		
		echo "Number of registers: " . $default_config->get( 'meta', 'num_registers' );
		
		// TODO - store data into arrays, use forms to get/view values
	?>
	</body>
</html>
