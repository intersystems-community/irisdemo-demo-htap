CREATE FUNCTION IRISDemo.DisableJournalForConnection(IN pDisable BIT DEFAULT 1) 
FOR IRISDemo.HTAPDemoAPI2
RETURNS VARCHAR(32000)
LANGUAGE OBJECTSCRIPT
{
	Set tSC = $$$OK
	Set tNS = $Namespace
	Try
	{
		If pDisable
		{
			Do $System.OBJ.SetTransactionMode(0, .tSC)
			Quit:$System.Status.IsError(tSC)
			
			Set $Namespace="%SYS"
			
			Do DISABLE^%SYS.NOJRN
		}
		Else
		{
			Do $System.OBJ.SetTransactionMode(1, .tSC)
			Quit:$System.Status.IsError(tSC)
			
			Set $Namespace="%SYS"
			
			Do ENABLE^%SYS.NOJRN
		}		
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