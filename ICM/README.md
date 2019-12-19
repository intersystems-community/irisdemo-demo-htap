# Using ICM with AWS

This folder has scripts that are written to make using ICM with AWS very easy.

First, you open a terminal and run the icm.sh script to start the icm container.

Then, from inside the ICM container, you change to the directory /ICMDurable:

```bash
cd /ICMDurable
```

Then, there will be the following scripts available:
* setup.sh - Use this script to set ICM up. It will ask you about things such as:
  * A label for the machines that ICM will create on AWS so that you can quickly find them by filtering by this label
  * If you want IRIS with Mirroring or not
  * How many Speed Test masters do you want. If you are testing only IRIS, you will need just one master. But if you are testing against other databases such as SAP HANA, you may ask for 2 masters (one for IRIS and another for SAP HANA)
  * How many ingestion workers per master
  * How many query workers per master
  * What are your docker hub credentials

## Setup

Run the setup.sh script and answer the questions. It will generate:
* defaults.json - This includes everything about IRIS and your docker hub credentials
* definitions.json - This includes the infrastructure configuration we want
* aws.credentials - This file is for you to paste your AWS credentials so that ICM can provision the infrastructure

The next step are:
* Go to AWS and copy your credentials and paste it on file aws.credentials.
* Save your iris.key file to the ./ICMDurable/license/ folder.

Now you are ready to provision the Infrastructure!

## Provision

Run the provision.sh script. It will create the machines on AWS.

## Deploy IRIS

Run the deployiris.sh script. It deploy InterSystems IRIS for you.

You will notice that ICM will write on the screen the URL for the management portal. Save that. You will be able to open the management portal using the user SuperUser and the password sys. Notice that there is a namespace called SPEEDTEST. This is where the speed test table will be created. You will be able to look at its contents during and after the speed test is run.

## Deploy the Speed Test

Run the deployspeedtest.sh script. Choose the database you want to test. It will deploy the speed test for the chosen database. 

If you choose IRIS, it will automatically configure the speed test to the IRIS end point you just deployed. Take note of the URL where the IRIS Speed Test UI is deployed and open it. 

You will set the **Run Test** button. Click on it to start the speed test.

## Unprovision

Run the unprovision.sh script. It will destroy all the machines, storage and network configurations provisioned.