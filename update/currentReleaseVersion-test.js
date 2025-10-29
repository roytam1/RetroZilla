function currentReleaseVersion() {
	
	// hack to fix updating for versions prior to 2.3
	var url = "https://rn10950.github.io/RetroZillaWeb/update.html";
	var upLink = document.getElementById('updateNotifier');
	upLink.innerHTML = '<a href="' + url + '">New RetroZilla Version Available</a>';
	
	return 230;
}