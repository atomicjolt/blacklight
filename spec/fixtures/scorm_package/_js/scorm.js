function exitCourse() 
{		
	var api = getAPIHandle();

	if (api != null)
	{
		api.LMSSetValue("cmi.core.exit", "suspend");
 		api.LMSFinish("");
	}
	else
	{
		var win = window.open("","_top","","true");
  		win.opener = true;  
  		win.close();
	}
}

var debug = true;  // set this to false to turn debugging off
var output = window.console; // output can be set to any object that has a log(string) function
                             // such as: var output = { log: function(str){alert(str);} };

// Define exception/error codes
var _NoError = {"code":"0","string":"No Error","diagnostic":"No Error"};
var _GeneralException = {"code":"101","string":"General Exception","diagnostic":"General Exception"};

var initialized = false;
var apiHandle = null;

function doLMSFinish()
{
   var api = getAPIHandle();
   
   if (api == null)
   {
      message("Unable to locate the LMS's API Implementation.\nLMSFinish was not successful.");
      return "false";
   }
   else
   {
      var result = api.LMSFinish("");
	  
      if (result.toString() != "true")
      {
         var err = ErrorHandler();
         message("LMSFinish failed with error code: " + err.code);
      }
   }
   initialized = false;   
   return result.toString();
}

function doGetValue(name)
{
   var api = getAPIHandle();
   var result = "";
   
   if (api == null)
   {
      message("Unable to locate the LMS's API Implementation.\nLMSGetValue was not successful.");
   }
   else
   {
      result = api.LMSGetValue(name);
      var error = ErrorHandler();
	  
      if (error.code != _NoError.code)
      {
         message("LMSGetValue("+name+") failed. \n"+ error.code + ": " + error.string);
         result = "";
      }
   }
   return result.toString();
}

function doSetValue(name, value)
{
   var api = getAPIHandle();
   var result = "false";
   
   if (api == null)
   {
      message("Unable to locate the LMS's API Implementation.\nLMSSetValue was not successful.");
   }
   else
   {
      result = api.LMSSetValue(name, value);
	  result = api.LMSSetValue("cmi.core.exit", "suspend");
	  
      if (result.toString() != "true")
      {
         var err = ErrorHandler();
         message("LMSSetValue("+name+", "+value+") failed. \n"+ err.code + ": " + err.string);
      }
   }
   return result.toString();
}

function doLMSCommit()
{
   var api = getAPIHandle();
   var result = "false";
   
   if (api == null)
   {
      message("Unable to locate the LMS's API Implementation.\nLMSCommit was not successful.");
   }
   else
   {
      result = api.LMSCommit("");
	  
      if (result != "true")
      {
         var err = ErrorHandler();
         message("LMSCommit failed - error code: " + err.code);
      }
   }
   return result.toString();
}

function doLMSGetLastError()
{
   var api = getAPIHandle();
   
   if (api == null)
   {
      message("Unable to locate the LMS's API Implementation.\nLMSGetLastError was not successful.");
      return _GeneralException.code; //General Exception
   }
   return api.LMSGetLastError().toString();
}


function doLMSGetErrorString(errorCode)
{
   var api = getAPIHandle();
   
   if (api == null)
   {
      message("Unable to locate the LMS's API Implementation.\nLMSGetErrorString was not successful.");
      return _GeneralException.string;
   }
   return api.LMSGetErrorString(errorCode).toString();
}

function doLMSGetDiagnostic(errorCode)
{
   var api = getAPIHandle();
   
   if (api == null)
   {
      message("Unable to locate the LMS's API Implementation.\nLMSGetDiagnostic was not successful.");
      return "Unable to locate the LMS's API Implementation. LMSGetDiagnostic was not successful.";
   }
   return api.LMSGetDiagnostic(errorCode).toString();
}

function ErrorHandler()
{
   var error = {"code":_NoError.code, "string":_NoError.string, "diagnostic":_NoError.diagnostic};
   var api = getAPIHandle();
   
   if (api == null)
   {
      message("Unable to locate the LMS's API Implementation.\nCannot determine LMS error code.");
      error.code = _GeneralException.code;
      error.string = _GeneralException.string;
      error.diagnostic = "Unable to locate the LMS's API Implementation. Cannot determine LMS error code.";
      return error;
   }

   // check for errors caused by or from the LMS
   error.code = api.LMSGetLastError().toString();
   
   if (error.code != _NoError.code)
   {
      // an error was encountered so display the error description
      error.string = api.LMSGetErrorString(error.code);
      error.diagnostic = api.LMSGetDiagnostic(""); 
   }
   return error;
}

function getAPIHandle()
{
   if (apiHandle == null)
   {
      apiHandle = getAPI();
   }
   return apiHandle;
}


function findAPI(win)
{
	var findAPITries = 0;
	
	while ((win.API == null) && (win.parent != null) && (win.parent != win))
	{
		findAPITries++;
      	// Note: 7 is an arbitrary number, but should be more than sufficient
      	if (findAPITries > 7) 
      	{
			message("Error finding API -- too deeply nested.");
			return null;
		}      
		win = win.parent;
	}
	return win.API;
}

function getAPI()
{
   var theAPI = findAPI(window);
   
   if ((theAPI == null) && (window.opener != null) && (typeof(window.opener) != "undefined"))
   {
      theAPI = findAPI(window.opener);
   }
   
   if (theAPI == null)
   {
      message("Unable to find an API adapter");
   }
   return theAPI
}

function message(str)
{
   if(debug)
   {
      //output.log(str);
   }
}

//*********************************************Functions that use SCORM funtions, Lesson Location, Suspend Data, Comments

