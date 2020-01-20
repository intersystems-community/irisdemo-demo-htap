CREATE FUNCTION IRISDemo.EnableCallInService() 
FOR IRISDemo.HTAPDemoAPI2
RETURNS VARCHAR(32000)
LANGUAGE OBJECTSCRIPT
{
	Set tSC = $$$OK
	Set tNS = $Namespace
	Try
	{
		Set $Namespace="%SYS"

		Set tSC = ##class(Security.Services).Get("%Service_CallIn", .serviceProperties)
		Quit:$$$ISERR(tSC)

		Set serviceProperties("Enabled")=1

		Set tSC = ##class(Security.Services).Modify("%Service_CallIn", .serviceProperties)
	}
	Catch (oException)
	{
		Set tSC = oException.AsStatus()
	}
	
	Set $Namespace=tNS
	
	If $$$ISERR(tSC)
	{
		Quit $System.Status.GetErrorText(tSC)
	}
	
	Quit 1
}
GO