<?php
	session_start();
?>

<html>
	<head>
		<title>PixelPi Command Viewer</title>

                <style type="text/css">
                        p { margin-left:28px; }
                        p { color:white; }
                        body { background: rgba( 0,0,0, .8 );
			/*	background-image:url('/backgroundImage/TX_ASIC_Black.png');*/
			 }

			body:after {
				content: "";
				background:url('/backgroundImage/TX_ASIC_Black.png');
				opacity: 0.2;
				top: 0;
				left: 0;
				bottom: 0;
				right: 0;
				position: absolute;
				z-index: -1;
			}

                        UL {
                                background: black;
                                margin: 12px 12px 12px 12px;
                                padding: 3px 3px 3px 3px;
                                width: 212px;
				border-style:solid;
				border-width:1px;
				border-color:white;
                        }

                        LI {
                                background:#333333;
                                width:200px;
                                margin: 12px 12px 12px 12px;
                                padding: 12px 12px 12px 12px;
                                list-style: none;
				border-style:inset;
				border-width:2px;
				border-color:gold;
                        }

			LI2 {
				
				margin-left: 20px;
				color: white;
			}

			UL2 {
			}

                        LI.withborder {
                                border-width:1px;
                                border-color:gold;
                        }

			#sidebar {
				border-top: 3px solid #99CC33;
				border-right: 2px solid #99CC33;
				height: 300px;
				width: 200px;
				float: right;
				margin-right: 120px;
				margin-top: 53px;
				background:#333333;
				padding: 5px 0 0 5px;
			}
/*	
			#sidebar2 {
				border-top: 1px solid #99CC33;
				border-left: 1px solid #99CC33;
				height: 300px;
				width: 200px;
				float: left;
				margin-top: 53px;
				padding: 5px 0 0 5px;
			}
*/
			END {
				position: absolute;
				bottom: 5px;
				text-align: center
			}

                </style>  
	
		<div id="sidebar"><font color="white">
			<h3>PixelPi Documentation <br><center>& More</center></h3>
			<p> Links to Team Pages </p>
			<ul2>
				<li2><a href="http://seniordesign.engr.uidaho.edu/2012-2013/pixelperfect/index.html"><font color="orange">Pixel Perfect	</font></a></li2> <BR><BR>
				<li2><a href="http://www2.cs.uidaho.edu/~cs480c/"><font color="orange">BitBangerFF	</font></a></li2>
				<BR><BR>
				<li2><a href="http://www.uidaho.edu/"><font color="orange">University of Idaho </font></a></li2>
				<BR><BR>
				
			</ul2>
		</font></div>
	
	</head>
	<body>

	<?php
		// include the system resources
		include 'sys_res/system.php';
	
		// print the title
		echo '<p><center><font size="6" color="white">PixelPi SSLAR Viewer</font></center></p><hr />';		

		// print the server time
		// should use javascript to update
		//echo "<p>Current Server Time: " . $current_date . "</p>";

		include 'image_res/stream-capture.php';

		// testing javascript server time
		//include 'st-js.php';

		echo "<p></p>";

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

		$start_button = $_POST['start_capture_b'];
		if( isset( $start_button ) )
        {
			// start daemon
			exec('/usr/local/bin/sslard');
        }

		$stop_button = $_POST['stop_capture_b'];
        if( isset( $stop_button ) )
        {
            // stop daemon
            exec('/usr/local/bin/sslard -q');
        }

	?>

		<SPAN style="position: absolute; top: 100px; left: 358px; width 100px; height: 60px;">
                        <UL>
                                <LI><font color="purple">-</font><font size="4" color="white"> Real-Time Data Feed </font><font color="purple">-</font></LI>

                                <LI class="withborder"> <font color="white"> Frame Rate:
                                              <P></P>
                                              Whitebalance:
                                              <P></P>
                                              Gain:
                                              <P></P>                         </font></LI>
                </UL>
        </SPAN> 
		
	</body>
	<END> &#169 2013 BitBangerFF & the University of Idaho </END>
</html>
