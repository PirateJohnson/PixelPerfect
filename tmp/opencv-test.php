<?php
//face.php -> detects faces and draws a pink square on faces

function LoadJpeg($imgname)
{
    $im = @imagecreatefromjpeg($imgname); /* Attempt to open */
    if (!$im) { /* See if it failed */
        $im  = imagecreate(150, 30); /* Create a blank image */
        $bgc = imagecolorallocate($im, 255, 255, 255);
        $tc  = imagecolorallocate($im, 0, 0, 0);
        imagefilledrectangle($im, 0, 0, 150, 30, $bgc);
        /* Output an errmsg */
        imagestring($im, 1, 5, 5, "Error loading $imgname", $tc);
    }
    return $im;
}

	$total= face_count($_GET['file'],'opencv_res/haarcascade_frontalface_alt.xml');
	$ord= face_detect($_GET['file'],'opencv_res/haarcascade_frontalface_alt.xml');

	$im = LoadJpeg($_GET['file']);
	$pink = imagecolorallocate($im, 255, 105, 180);

if(count($ord) > 0) {

	foreach ($ord as $arr) {
		imagerectangle($im,$arr['x'] ,$arr['y'] , $arr['x']+$arr['w'],
		$arr['y']+$arr['h'], $pink);
	}

}
	header('Content-Type: image/jpeg');
	imagejpeg($im);
	imagedestroy($im);
?>

