var link_array = new Array();
var modNum = "M2";
var numPages = 31;

for (i = 0; i < numPages; i++)
{
	var prefix = "00";
	
	if (i > 8)
	{
		prefix = "0";
	}
	else if (i > 98)
	{
		prefix = "";
	}
	
	link_array[i] = modNum + "_" + prefix + (i + 1) + ".htm";
} 