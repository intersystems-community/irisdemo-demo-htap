package com.irisdemo.htap.worker.postgres;


import java.util.Date;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

import java.util.Random;

public class Util
{    
    private static final String ALPHA_NUMERIC_STRING = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    public static String randomAlphaNumeric(int count) 
    {
    	StringBuilder builder = new StringBuilder();
	    while (count-- != 0) 
	    {
	    	int character = (int)(Math.random()*ALPHA_NUMERIC_STRING.length());
	    	builder.append(ALPHA_NUMERIC_STRING.charAt(character));
	    }
	    
	    return builder.toString();
    }
    
    public static Date randomDate()
    {
    	Random  rnd;
    	long    ms;

    	// Get a new random instance, seeded from the clock
    	rnd = new Random();

    	// Get an Epoch value roughly between 1940 and 2010
    	// -946771200000L = January 1, 1940
    	// Add up to 70 years to it (using modulus on the next long)
    	//ms = -946771200000L + (Math.abs(rnd.nextLong()) % (70L * 365 * 24 * 60 * 60 * 1000));
    	ms = -946771200000L + (Math.abs(rnd.nextLong()/1000L) % (70L * 365 * 24 * 60 * 60)*1000);

    	// Construct a date
    	return new Date(ms);
    }

    public static java.sql.Timestamp randomTimeStamp()
    {
    	return new Timestamp(randomDate().getTime());
    }

    public static String randomMySQLStringTimeStamp()
    {
    	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    	return sdf.format(randomDate());
    }
    
    
}