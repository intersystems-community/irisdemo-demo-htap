CREATE FUNCTION IRISDemo.GetFreeSpaceInMb(OUT pFreeDiskSpaceInMB INT) 
FOR IRISDemo.HTAPDemoAPI2
RETURNS VARCHAR(32000)
LANGUAGE OBJECTSCRIPT
{
	Set tSC = $$$OK
	Try
	{			
		Set pFreeDiskSpaceInMB=-1
		Set tMainDatabaseDir = $System.Util.DataDirectory()
		
		Set tNS = $Namespace
		ZN "%SYS"

		Set tSC = ##class(SYS.Database).GetFreeSpace(tMainDatabaseDir, .pFreeDiskSpaceInMB, .ignoredFreeBlocks)
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