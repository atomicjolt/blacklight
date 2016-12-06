// Globals
var requiredMajorVersion = 10;
var hasFlashVersion = false;
var xh;

if (FlashDetect.installed)
{
	if (FlashDetect.major >= requiredMajorVersion)
	{
		hasFlashVersion = true;
	}
}

var checkWidth = 0;
var checks = 0;

function checkReq()
{
	if (xh != "Enabled")
	{
		document.getElementById("main").style.visibility = "visible";
		document.getElementById("xmlhttp").style.visibility = "visible";
		checks++;
	}
	else
	{	
		document.getElementById("xmlhttp").innerHTML = "";
	}
	
	if (!hasFlashVersion)
	{
		document.getElementById("main").style.visibility = "visible";
		document.getElementById("flash").style.visibility = "visible";
		checks++;
	}
	else
	{	
		document.getElementById("flash").innerHTML = "";
	}	
	
	if (!cookies)
	{
		document.getElementById("main").style.visibility = "visible";
		document.getElementById("cookie").style.visibility = "visible";
		checks++;
	}
	else
	{	
		document.getElementById("cookie").innerHTML = "";
	}	
		
	if (checkWidth < 1024)
	{
		document.getElementById("main").style.visibility = "visible";
		document.getElementById("screen").style.visibility = "visible";
		checks++;
	}
	else
	{	
		document.getElementById("screen").innerHTML = "";
	}	
	
	if (checks == 0)
	{
		enterCourse();
	}
}

function enterCourse()
{
	document.location.href = startPage;
}

function checkCourse()
{
	window.location.reload();
}

document.writeln('<div id="main">\r\n	<h1>System Requirements<\/h1>\r\n	<p>Problems have been detected with your system configuration that you may cause you to experience difficulty launching or completing this course. The recommended software and settings for courseware running in this Learning Management System (LMS) are listed below.&nbsp; If your configuration is different from these settings, fix the indicated problems by following the applicable instructions below.<\/p>\r\n	<p>When you have resolved all issues, click the Test button below. If the issues are resolved you will immediately start the course.<\/p>\r\n	<p>\r\n		<input type="submit" id="check" name="check" title="test" value="      Test      " onClick="javascript:checkCourse();"\/>\r\n	<\/p>\r\n	<p>If you cannot resolve the issue(s) immediately, click the Start Course button to access the course.<\/p>\r\n	<p>\r\n	<input type="submit" id="start" name="start" title="start" value="Start Course" onClick="javascript:enterCourse();"\/>\r\n	<\/p>\r\n	<table>\r\n		<tr>\r\n			<td width="50%" valign="top"><table border="0" cellpadding="0" cellspacing="0" bordercolor="#111111" width="100%" id="AutoNumber2">\r\n					<tr>\r\n						<td width="49%" align="right"><p><b>Required Configuration<\/b><\/p><\/td>\r\n						<td width="2%" align="center"><p><b> | <\/b><\/p><\/td>\r\n						<td width="49%" align="left"><p><b>Current Configuration<\/b><\/p><\/td>\r\n					<\/tr>\r\n					<tr>\r\n						<td width="49%" align="right" bgcolor="#EBEBEB"><p>Microsoft Windows 2000, XP, Vista or 7 Operating System<\/p><\/td>\r\n						<td width="2%" align="center" bgcolor="#EBEBEB"><p><b> | <\/b><\/p><\/td>\r\n						<script>\r\n        				document.write(\'<td width="%49" bgcolor="#EBEBEB">\');\r\n						\r\n        				var os = getOSName();\r\n						\r\n						document.write(\'<p class="good">\'+os+\'<\/p><\/td>\');\r\n        			<\/script> \r\n					<\/tr>\r\n					<tr>\r\n						<td width="49%" align="right"><p>Internet Explorer 8 +<\/p><\/td>\r\n						<td width="2%" align="center"><p><b> | <\/b><\/p><\/td>\r\n						<script>\r\n        				document.write(\'<td width="49%">\');\r\n						\r\n        				var name, version;\r\n						name = getBrowserName();\r\n						version = getBrowserVersion(); \r\n				\r\n						if (version >= 8)\r\n						{\r\n							document.write(\'<p class="good">\'+name + \' \' + version+\'<\/p><\/td>\');\r\n						} \r\n						else \r\n						{\r\n							document.write(\'<p class="bad">\'+name + \' \' + version+\'<\/p><\/td>\');							\r\n						}\r\n					<\/script> \r\n					<\/tr>\r\n					<tr>\r\n						<td width="49%" align="right" bgcolor="#EBEBEB"><p>Native XMLHTTP enabled<\/p><\/td>\r\n						<td width="2%" align="center" bgcolor="#EBEBEB"><p><b> | <\/b><\/p><\/td>\r\n						<script>\r\n						document.write(\'<td width="49%" bgcolor="#EBEBEB">\');\r\n						\r\n						var xh = checkXMLHTTP();\r\n												\r\n						if (xh == "Enabled")\r\n						{\r\n							document.write(\'<p class="good">\'+xh+\'<\/p><\/td>\');					\r\n						} \r\n						else \r\n						{\r\n							document.write(\'<p class="bad">\'+xh+\'<\/p><\/td>\');						\r\n						}						\r\n					<\/script> \r\n					<\/tr>\r\n					<tr>\r\n						<td width="49%" align="right"><p>Flash Player 10 +<\/p><\/td>\r\n						<td width="2%" align="center"><p><b> | <\/b><\/p><\/td>\r\n						<script>\r\n						document.write(\'<td width="49%">\');\r\n						\r\n						var versionStr = FlashDetect.raw;\r\n												\r\n						if (hasFlashVersion)\r\n						{\r\n							document.write(\'<p class="good">\'+versionStr+\'<\/p><\/td>\');					\r\n						} \r\n						else \r\n						{\r\n							document.write(\'<p class="bad">\'+versionStr+\'<\/p><\/td>\');						\r\n						}						\r\n					<\/script> \r\n					<\/tr>\r\n					<tr>\r\n						<td width="49%" align="right" bgcolor="#EBEBEB"><p>JavaScript enabled<\/p><\/td>\r\n						<td width="2%" align="center" bgcolor="#EBEBEB"><p><b> | <\/b><\/p><\/td>\r\n						<script>\r\n						document.write(\'<td width="49%" bgcolor="#EBEBEB"><p class="good">Yes<\/p><\/td>\');						\r\n					<\/script> \r\n					<\/tr>\r\n					<tr>\r\n						<td width="49%" align="right"><p>Cookies enabled<\/p><\/td>\r\n						<td width="2%" align="center"><p><b> | <\/b><\/p><\/td>\r\n						<script>\r\n						document.write(\'<td width="49%" bgcolor="#FFFFFF">\');\r\n						var cookies;\r\n						cookies = CheckCookies();\r\n		\r\n						if (cookies)\r\n						{\r\n							document.write(\'<p class="good">Yes\');							\r\n						} \r\n						else \r\n						{\r\n							document.write(\'<p class="bad">No\');							\r\n						}\r\n						document.write(\'<\/p><\/td>\');\r\n					<\/script> \r\n					<\/tr>\r\n					<tr>\r\n						<td width="49%" align="right" bgcolor="#EBEBEB"><p>1024 x 768 Screen Resolution<\/p><\/td>\r\n						<td width="2%" align="center" bgcolor="#EBEBEB"><p><b> | <\/b><\/p><\/td>\r\n						<script>\r\n						document.write(\'<td width="49%" bgcolor="#EBEBEB">\');\r\n						var height;\r\n						checkWidth = getScreenWidth();\r\n						height = getScreenHeight();	\r\n								\r\n						if (checkWidth >= 1024)\r\n						{\r\n							document.write(\'<font color="#0000FF">\');\r\n							document.write(\'<p>\'+checkWidth+\' x \'+height+\'<\\\/p>\');\r\n							document.write(\'\');\r\n							document.write(\'<\/td>\');\r\n						} \r\n						else \r\n						{\r\n							document.write(\'<font color="#ff000c">\');\r\n							document.write(\'<p>\'+width+\' x \'+height+\'<\\\/p>\');\r\n							document.write(\'\');\r\n							document.write(\'<\/td>\');\r\n						}\r\n						document.write(\'<\/td>\');\r\n					<\/script> \r\n					<\/tr>\r\n				<\/table><\/td>\r\n		<\/tr>\r\n	<\/table>\r\n	<ul class="trademark">\r\n		<li><em>Internet Explorer is either a registered trademark or trademark of Microsoft Corporation in the United States and\/or other countries.<\/em><\/li>\r\n		<li><em>Microsoft is either a registered trademark or trademark of  Microsoft Corporation in the United States and\/or other countries.<\/em><\/li>\r\n		<li><em>Windows is a registered trademark of Microsoft Corporation in the United States and other countries.<\/em><\/li>\r\n		<li><em>JavaScript is a trademark of Sun Microsystems, Inc.<\/em><\/li>\r\n	<\/ul>\r\n	<br>\r\n<\/div>\r\n<div id="xmlhttp">\r\n	<h2>XMLHTTP Support<\/h2>\r\n	<table width="800" border="0">\r\n		<tr>\r\n			<td width="800" valign="top"><p>This content requires that XMLHTTP is enabled.<\/p>\r\n				<ol>\r\n					<li>From the browser\'s menu bar, select Tools.<\/li>\r\n					<li>Select Internet Options.<\/li>\r\n					<li>Select the  Advanced tab.<\/li>\r\n					<li>Scroll down to  the Security submenu.<\/li>\r\n					<li>Select Enable native XMLHTTP support.<br \/>\r\n					<\/li>\r\n				<\/ol><\/td>\r\n			<td width="800"><p><img src="..\/..\/systemCheck\/XMLHTTP_Support.jpg" width="423" height="541" \/><\/p><\/td>\r\n		<\/tr>\r\n	<\/table>\r\n<\/div>\r\n<div id="flash">\r\n	<h2>Flash Player<\/h2>\r\n	<p>This content requires the Adobe Flash Player and Internet Explorer with JavaScript enabled. You may click the Flash Icon below or contact your System Administrator to install the latest version of the Flash Player for you.<\/p>\r\n	<p> <a href="https:\/\/www.adobe.com\/go\/getflash\/"><img src="..\/..\/systemCheck\/flash_64.jpg" width="64" height="63" alt="Flash logo"><\/a><\/p>\r\n	<p class="trademark"><em>Adobe, the Adobe logo and Flash are either registered trademarks   or trademarks of Adobe Systems Incorporated in the United States and\/or other   countries. <\/em><\/p>\r\n<\/div>\r\n<div id="cookie">\r\n	<h2>Cookies<\/h2>\r\n	<p>Many courses use temporary or session cookies to store exercise completion and other course information. A temporary or session cookie is created only for your current browsing session and is deleted from your computer after 30 days. Below are the steps to enable Cookies or determine if they are enabled. Some personal firewall products can be configured to high security mode which blocks all cookies, so if you are using any personal  firewall software then please consult it\'s documentation on the matter of session cookies.<\/p>\r\n	<h3>Enable Cookies for Internet Explorer<\/h3>\r\n	<ol>\r\n		<li>From the browser\'s menu bar, select Tools.<\/li>\r\n		<li>Select Internet Options.<\/li>\r\n		<li>Select  Privacy tab.<\/li>\r\n		<li>Adjust the settings to <i>Medium High<\/i> or lower.<\/li>\r\n		<li>Select OK.<\/li>\r\n		<li>Select OK.<\/li>\r\n	<\/ol>\r\n	<p>&nbsp;&nbsp;&nbsp; If your browser is still refusing to accept session cookies then it may be necessary to do the following:<\/p>\r\n	<ol>\r\n		<li>From the browser\'s menu bar, select Tools.<\/li>\r\n		<li>Select Internet Options.<\/li>\r\n		<li>Select Privacy tab.<\/li>\r\n		<li>Select Advanced.<\/li>\r\n		<li>Make sure the <i>Override Automatic Cookie Handling<\/i> is checked.<\/li>\r\n		<li>Make sure that <i>Always allow session cookies<\/i> is checked.<\/li>\r\n	<\/ol>\r\n<\/div>\r\n<div id="screen">\r\n	<h2>Screen Resolution<\/h2>\r\n	<p>A screen resolution of 1024 x 768 is recommended for all courses. This resolution  will minimize scrolling and make the screen easier to read. Below are the steps to set or determine the screen resolution.<\/p>\r\n	<ol>\r\n		<li>From your desktop, right-click and choose Properties<\/li>\r\n		<li>Select the Settings tab<\/li>\r\n		<li>In the Screen Area section, move the slider pointer to 1024x768 pixels<\/li>\r\n		<li>Select OK<\/li>\r\n		<li>A popup dialog box will appear asking for confirmation of your selection. Select OK again. You screen may flicker or go blank for a few seconds as it changes resolution. This is normal.<\/li>\r\n		<li>A dialog box will then appear asking if you wish to keep this setting.&nbsp;<\/li>\r\n		<li> Select Yes<\/li>\r\n	<\/ol>\r\n<\/div>');