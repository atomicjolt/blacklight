var count = 0; 
var str = "";
var lastPage = false;
var netConnected = false;
var myProgress = 0;

function parseFileName(str) 
{ 
	var slash = '/'; 
	
	if (str.match(/\\/)) 
	{ 
		slash = '\\' ;
	}	
	
	if (str.split(":")[0] == "http" || str.split(":")[0] == "https")
	{
		netConnected = true;
	}
	 
	return str.substring(str.lastIndexOf(slash) + 1, str.lastIndexOf('.')) ;
}

var thisID = parseFileName(document.location.href)
var activePage = thisID+".htm";

if (netConnected)
{
	myProgress = doGetValue("cmi.comments");
}
else
{
	myProgress = link_array.length;
}

for (var i = 0; i < link_array.length; i++)//find position in link_array
{
	if (activePage == link_array[i])
	{
		count = i;
		
		if (netConnected && count == link_array.length - 1)
		{
			doSetValue("cmi.core.lesson_location", 0);
			doSetValue("cmi.suspend_data", 2);
			doSetValue("cmi.core.lesson_status", "completed");
		}
		
		break;
	}
}

var pageComplete = false;
var courseComplete = doGetValue("cmi.core.lesson_status");

if (myProgress.length > count || courseComplete == "completed")
{
	pageComplete = true;
}

function displayPageNum()
{
	var obj = document.getElementById("pageNum");
	
	if (obj != null)
	{
		obj.innerHTML = "Page " + (count + 1) + " of " + link_array.length;
	}
	
	if (pageComplete)
	{
		var tempObj = document.getElementById('ForwardOff');
		
		if (tempObj)
		{
			turnOnDiv();
		}
	}
}

// move forward a page
function goNext()
{
	if (netConnected)
	{
		if (myProgress.length == count)
		{
			doSetValue("cmi.comments", "1");
		}
	
		doSetValue("cmi.core.lesson_location", count + 1);
	}
	
	count = count + 1;
	
	window.location.href = link_array[count];	
}
 
// move back a page
function goBack()
{
	if (netConnected)
	{
		doSetValue("cmi.core.lesson_location", count - 1);
	}
	
	count = count - 1;
	window.location.href = link_array[count];	
}

function turnOffDiv() 
{
	document.getElementById('ForwardOff').style.display = 'inline';
	document.getElementById('ForwardOn').style.display = 'none';
}

function turnOnDiv() 
{	
	document.getElementById('ForwardOff').style.display = 'none';
	document.getElementById('ForwardOn').style.display = 'inline';
}

