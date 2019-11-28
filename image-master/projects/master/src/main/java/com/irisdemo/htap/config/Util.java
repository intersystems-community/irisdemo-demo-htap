package com.irisdemo.htap.config;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ClassPathResource;

public class Util
{    

	public static BufferedReader getBufferedReaderForFile(String fileName) throws IOException
	{
		BufferedReader reader;
		
		try
		{
			Resource resource = new ClassPathResource(fileName);
			reader = new BufferedReader(new InputStreamReader(resource.getInputStream()));
		}
		catch (FileNotFoundException e)
		{
			InputStream file = new FileInputStream("./sql/"+fileName);
			reader = new BufferedReader(new InputStreamReader(file));
		}
		
		return reader;
	}
	
	public static String getSingleStatementFromFile(String fileName) throws IOException
	{
		BufferedReader reader = getBufferedReaderForFile(fileName);
		
		StringBuilder statementSB = new StringBuilder();
		
		String line = reader.readLine();
		
	    while ((line != null) && (!line.equals("GO")))
	    {
	    	statementSB.append(line);
	    	statementSB.append(System.lineSeparator());
	        line = reader.readLine();
	    }
		
		return statementSB.toString();
	}
}