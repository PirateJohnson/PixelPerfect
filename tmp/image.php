<?php
   header('Content-Type: image/jpeg');
   include('SimpleImage.php');
   $image = new SimpleImage();
   $image->load('face-200x150.jpg');
   $image->resizeToWidth(550);
   $image->output(IMAGETYPE_JPEG);
?>
