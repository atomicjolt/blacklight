
function getBrowserName()
{
	var agt = navigator.userAgent.toLowerCase();

	var ie6 = ((agt.indexOf('msie 6') > 0)) ? true:false;
	var ie7 = ((agt.indexOf('msie 7') > 0)) ? true:false;
	var ie8 = ((agt.indexOf('msie 8') > 0)) ? true:false;
	var ie9 = ((agt.indexOf('msie 9') > 0)) ? true:false;
	var ie10 = ((agt.indexOf('msie 10') > 0)) ? true:false;

	if(ie6 || ie7 || ie8 || ie9 || ie10)
	{
		return("Internet Explorer");
	}
	else 
	{
	    return("Unsupported");
	}
}

function getBrowserVersion()
{
	var ua = navigator.userAgent;

	if (/Trident[\/\s](\d+\.\d+)/.test(navigator.userAgent))
	{ //test for Trident token in IE8 and greater (ignoring remaining digits);
       var triVersion = new Number(RegExp.$1) // capture x.x portion and store as a number
	}

	if (ua.indexOf("MSIE") >= 1)
	{
		if(ua.indexOf("MSIE 6.0") >= 1)
		{
			return("6.0");
		}
		else if (ua.indexOf("MSIE 7.0") >= 1 && triVersion <= 0)
		{
			return("7.0");
		}
		else if (triVersion = 4)
		{
			return("8.0");
		}
		else if (triVersion = 5)
		{
			return("9.0");
		}
		else if (triVersion = 6)
		{
			return("10.0");
		}
	}
	else
	{
		return("Unsupported");
	}
}

function checkXMLHTTP()
{
   if (window.XMLHttpRequest) 
   {
      return("Enabled");
   }
   else
   {
	  return("Not Enabled");
   }
}

function getOSName()
{
	var ua = navigator.userAgent;

	if (ua.indexOf("Windows NT 6.1") >= 1)
	{
		return("Windows 7");
	}
	else if (ua.indexOf("Windows NT 6.0") >= 1)
	{
		return("Windows Vista");
	}
	else if (ua.indexOf("Windows NT 5.1") >= 1)
	{
		return("Windows XP");
	}
	else if (ua.indexOf("Windows NT 5.0") >= 1)
	{
		return("Windows 2000");
	}
	return("Not Supported");
}

function CheckJava()
{
	return(navigator.javaEnabled());
}

function CheckCookies()
{
	if (navigator.cookieEnabled)
	{
		document.cookie = "test="+escape('test');
		
		if(document.cookie == "")
		{
			return(false);
		}
		else
		{
			return(true);
		}
	}
	else
	{
		return(navigator.cookieEnabled);
	}
}

function getScreenWidth()
{
	return(screen.width);
}

function getScreenHeight()
{
	return(screen.height);
}