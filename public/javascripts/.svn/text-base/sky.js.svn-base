/* BOTP Sky! */

$j(function ($) {

/*
 * script entry
 */

function preloadImages(srcs, callback) {
	var count = 0;
	for (var i = 0; i < srcs.length; i++) {
		var img = new Image();
		img.onload = function () { count++; if (count == srcs.length - 1) callback(); }
		img.src = srcs[i];
		if (img.width) img.onload();
	}
}

function randomInt(min, max) {
	return Math.floor(Math.random() * (max - min)) + min;
}

var body = $('body');
body.append('<div id="sky-clouds"></div>');
var canvas = $('#sky-clouds');

// style canvas
var height = Math.max($(document).height(), $('body').height());
var width = $('body').width();
canvas.css({top: 0, left: 0, position: 'absolute', width: '100%', height: height, zIndex: '-5', overflow: 'hidden'});

// preload images
preloadImages(['/images/background/cloud_01.png', '/images/background/cloud_02.png' ,'/images/background/cloud_03.png'],
function () {

// generate clouds
var clouds = [];
for (var i = 0; i < 7; i++) {
	canvas.append('<div><img src="/images/background/cloud_0' + randomInt(1, 3) +'.png"></div>');
	var cloud = canvas[0].lastChild, cloudImage = cloud.firstChild;
	var rand = randomInt(10, 50)/100;
	cloudImage.width = cloudImage.width * rand;
	$(cloud).css({position: 'absolute', opacity: 0.5, top: randomInt((cloudImage.height / 2), height - cloudImage.height - 30) + 'px', left: randomInt(-cloudImage.width, width) + 'px'});
	clouds.push({node: cloud, image: cloudImage, velocity: randomInt(1,10)/10, left: parseInt(cloud.style.left)});
}

setInterval(function animate() {

for (var i = 0; i < clouds.length; i++) {
cloud = clouds[i];
cloud.left -= cloud.velocity;
if (cloud.left < -cloud.image.width) {
cloud.left = $('body').width();
cloud.node.style.top = randomInt((cloud.image.height / 2), height - cloud.image.height - 30) + 'px';
}
cloud.node.style.left = cloud.left + 'px';
}

}, 1000);
});

/*
 * end
 */
 
});