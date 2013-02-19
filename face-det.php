<?php
   header('Content-Type: image/jpeg');
   include('Face_Detector_Class.php');
   $image = new Face_Detector('detection.dat');
   $image->face_detect('face-200x150.jpg');
   $image->toJpeg();
?>
