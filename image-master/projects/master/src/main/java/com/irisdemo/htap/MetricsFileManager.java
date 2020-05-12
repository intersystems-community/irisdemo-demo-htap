package com.irisdemo.htap;

import org.springframework.context.annotation.Scope;
import org.springframework.http.CacheControl;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;

import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.config.ConfigurableBeanFactory;

@Component()
@Scope(value = ConfigurableBeanFactory.SCOPE_SINGLETON)
public class MetricsFileManager {
    private File metricsFile;
    private FileWriter metricsFileWriter;

    MetricsFileManager() throws Exception {
        openMetricsFile();
    }

    public void openMetricsFile() throws Exception {
        if (metricsFile != null) {
            metricsFile.delete();
        }

        metricsFile = File.createTempFile("temp", null);
        metricsFile.deleteOnExit();

        this.metricsFileWriter = new FileWriter(metricsFile);
        addHeaderLine();
    }

    private void addHeaderLine() throws IOException
    {
        StringBuffer str = new StringBuffer();

        str.append("timeInSeconds");
        str.append(",");
        str.append("numberOfActiveIngestionThreads");
        str.append(",");
        str.append("numberOfRowsIngested");
        str.append(",");
        str.append("recordsIngestedPerSec");
        str.append(",");
    	str.append("avgRecordsIngestedPerSec");
        str.append(",");
        str.append("MBIngested");
        str.append(",");
        str.append("MBIngestedPerSec");
        str.append(",");
    	str.append("avgMBIngestedPerSec");
    	str.append(",");
        str.append("numberOfRowsConsumed");
        str.append(",");
        str.append("numberOfActiveQueryThreads");
        str.append(",");
        str.append("recordsConsumedPerSec");
        str.append(",");
    	str.append("avgRecordsConsumedPerSec");
    	str.append(",");
        str.append("MBConsumed");
        str.append(",");
        str.append("MBConsumedPerSec");
        str.append(",");
    	str.append("avgMBConsumedPerSec");
    	str.append(",");
        str.append("queryAndConsumptionTimeInMs");
    	str.append(",");
        str.append("avgQueryAndConsumptionTimeInMs");

        metricsFileWriter.append(str + "\n");
    }

    public void appendMetrics(Metrics metrics) throws Exception {
        metricsFileWriter.append(metrics.toString() + "\n");
    }

    public FileInputStream getMetricsFileContents() throws IOException
    {
        try
        {
            if (metricsFile!=null)
            {
                metricsFileWriter.close();
                return new FileInputStream(metricsFile);
            }
        }
        catch (FileNotFoundException e)
        {
            
        }

        return null;
    }
    
    public ResponseEntity<byte[]> getMetricsFileAsResponseEntity(String fileName) throws IOException 
    {
        HttpHeaders headers = new HttpHeaders();
        headers.setCacheControl(CacheControl.noCache().getHeaderValue());

        ContentDisposition contentDisposition = ContentDisposition.parse("attachment;filename="+ fileName);
        
        headers.setContentDisposition(contentDisposition);

        byte[] media = IOUtils.toByteArray(getMetricsFileContents());

        ResponseEntity<byte[]> responseEntity = new ResponseEntity<>(media, headers, HttpStatus.OK);
        
        return responseEntity;   
    }
    
}