# InterSystems IRIS x SAP HANA on AWS

This document explains how to use the scripts we provide to quickly deploy the Speed Test against InterSystems IRIS and SAP HANA. If you haven't done so yet, please follow instructions [here](../README.md) for the initial setup. There you will also find a diagram of how this is going to work.

# Provisioning the Initial environment on AWS

On this step, we will provision the initial environment on AWS which includes all the machines for InterSystems IRIS, the InterSystems IRIS Speed Test and SAP HANA Speed Test. It will all be provisioned on the same VPC. We will later manually deploy SAP HANA on the same VPC as well.

We will also on this step deploy InterSystems IRIS and the Speed Test applications for both InterSystems IRIS and SAP HANA, so let's get to it!

## 1 - Start ICM

You have clonned this repo to a folder on your PC. Now, open a terminal and change to the ICM folder. Run the icm.sh script to start the icm container:

```bash
./icm.sh
```


Then, from inside the ICM container, you change to the directory /ICMDurable:

```bash
cd /ICMDurable
```

## 2 - Setup

Run the setup.sh script and answer the questions as follows:
 
```
/ICMDurable # ./setup.sh

Please enter with the label for your ICM machines (ex: asamaryTest1):
```
Answer: **asamarySAPHANA**

````
Do you want InterSystems IRIS with Mirroring (answer yes or something else if not)?:**
````
Answer: **no**

```
How many Speed Test Masters do you want?:
```
Answer: **2**

```
How many Ingestion Workers per Master?:
```
Answer: **1**

```
How many Query Workers per Master?:
```
Answer: **1**

```
Please enter with the AWS instance type:
```
Answer: **Pick the option for i3.xlarge**

```
Is this going to be a containerless installation of InterSystems IRIS (answer yes or something else if not)?:
```
Answer: **yes**

After this last question, you will see a message like:

```bash
ICM configured to provision i3.xlarge machines on AWS.
You can now change to /ICMDurable/Deployments/asamarySAPHANA and run ./provision.sh to provision the infrastructure on AWS.
```
So, change to the folder that it is indicating:

```
/ICMDurable # cd ./Deployments/asamarySAPHANA/
```

## 3 - Provision

Run the provision.sh script. It will create the machines on AWS:

```
/ICMDurable/Deployments/asamarySAPHANA # ./provision.sh
```

It should take about 2 minutes to finish.

### ICM Provision Troubleshooting

If ICM is taking a long time to run, that is because something bad is happening. It will stop eventually and tell you what is wrong. But if you want to look right now what is wrong instead of waiting, you can look at the terraform.err file and see what is happening:

```
/ICMDurable/Deployments/asamarySAPHANA # cat ./state/asamarySAPHANA-IRISSpeedTest/terraform.err
```

Just replace "asamarySAPHANA" by the label you picked which happens to be the name of the folder you are.

Either way, you will see the error eventually. Here is a list of errors I encountered:
* **ExpiredToken**: The security token included in the request is expired": Your AWS credentials have expired and you need to get a new one. Repeat the step "Getting your AWS Credentials" and just run the ./provision.sh script again.
* **Error import KeyPair: InvalidKeyPair.Duplicate: The keypair '?' already exists.**: There is already a key called ? on EC2. Open EC2 on AWS, go to Key Pairs, find it and delete it.

It is normal to see some instances of "SSH operation failed" on the output. The machines are being provisioned by AWS and ICM keeps trying to SSH into them to continue with the setup process. If AWS hasn't finished provisioning the machines, we will get an SSH error. That is normal and ICM will just retry. Don't worry.

## 4 - Deploy InterSystems IRIS

Run the **deployiris.sh** script. It deploys InterSystems IRIS for you:

```
/ICMDurable/Deployments/asamarySAPHANA # ./deployiris.sh
```

This script will make ICM copy the InterSystems IRIS install kit to the machine on AWS and install it. So depending on your network, it may be very fast or take longer. On my PC, running from the office, it took 3 minutes.

When done, you will notice that ICM will write on the screen the URL for the management portal. Save that. You can open the management portal using the user **SuperUser** and the password **sys**. You will notice that there is a namespace called SPEEDTEST. This is where the speed test table will be created. You will be able to look at its contents during and after the speed test is run. 

## 5 - Deploy the Speed Test for InterSystems IRIS

Run the **deployspeedtest.sh** script:

```
/ICMDurable/Deployments/asamarySAPHANA # ./deployspeedtest.sh
```

It will present you a menu asking which speed test you want to deploy. Choose the option for InterSystems IRIS:

```
Please, specify which speedtest you want to deploy. Available options are:

	 iris  - InterSystems IRIS

	 hana  - SAP HANA

	 aurora  - AWS Aurora

	 sqlserver  - AWS RDS SQL Server
```
Answer: **iris**

Deploying the Speed Test for InterSystems IRIS should take less then 2 minutes. You will see something like the following at the end:

```
URL to SpeedTest | InterSystems IRIS Speed Test is at:

	http://54.85.37.113

If you are planning on deploying SAP HANA, AWS Aurora or any other AWS database, deploy them on the VPC_ID vpc-0e1734aabf07ddba1.

Done!
```

Take note of this URL!

Also, please note that we have just told you the **AWS VPC_ID**. Take note of that! When deploying SAP HANA, you must deploy it on this VPC!

## 6 - Deploy SAP HANA 2.0 Express Edition

InterSystems IRIS and InterSystems IRIS Speed Test are deployed and you know the VPC_ID where they are. Here is what else we need to do:
* 6.1 - Manually deploy SAP HANA on the same **VPC_ID**
* 6.2 - Take note of its **Endpoint**.
* 6.3 - Configure SAP HANA

### 6.1 - Manually deploy SAP HANA

Click [here](https://aws.amazon.com/marketplace/pp/B086L36N2H?qid=1587590071891&sr=0-2&ref_=srh_res_product_title) to open SAP HANA Express 2.0 page on AWS:
* Click on the button **Continue to Subscribe**.
* On the next screen, click on the button **Accept Terms**. Wait for the screen to update and show the Effective subscription date.
* Click on the button **Continue to Configuration**
  * Pick "SAP HANA Express 2.0 Rev 45 (Apr 14, 2020)"
  * Pick Region "US East (N. Virginia)"
* Click on the button **Continue to Launch**
  * Pick EC2 Instance Type **i3.xlarge**. It has 4 cores, 30Gb of RAM and a very high network performance (up to 10Gigabit). InterSystems IRIS is deployed on the same machine.
  * Under VPC Settings, pick the VPC_ID that we gave just after you deployed InterSystems IRIS.
  * Under Security Group Settings, pick the security group that has the form **YourLabel-CN-IRISSpeedTestext**
  * Under Key Pair Settings, pick the key named **YourLabel-CN-IRISSpeedTest**
* Click on the button **Launch**

You should see a **Congratulations** message now. SAP HANA is being provisioned and deployed on our VPC!

### 6.2 - Take note of SAP HANA's Endpoint

SAP HANA will be deployed as an EC2 box. So we can open AWS **EC2 Dashboard** and find it there. It will help if you filter by your label. You should see an i3.xlarge machine with no name on your list. That's SAP HANA. It will have the state "Initializing" for a while.

While it is being deployed, we can take note of its endpoint. InterSystems IRIS will be talking to SAP HANA through its **Private IP**. If you click on the machine, it will appear under the **Description** tab just bellow. Take note of that.

Also take note of its **Public IP** so we can use it to configure SAP HANA.

### 6.3 - Configure SAP HANA

Now, let's use the Public IP of SAP HANA to configure it. In my case, SAP HANA was assigned the public IP 18.209.45.217. So, go back to your ICM session on your terminal and type the following:

```
/ICMDurable/Deployments/asamarySAPHANA # ssh -i /ICMDurable/keys/insecure ec2-user@18.209.45.217

Last login: Wed Mar  4 15:46:06 2020 from 12.226.24.14
SUSE Linux Enterprise Server 12 SP3 x86_64 (64-bit)

As "root" (sudo or sudo -i) use the:
  - zypper command for package management
  - yast command for configuration management

Management and Config: https://www.suse.com/suse-in-the-cloud-basics
Documentation: https://www.suse.com/documentation/sles-12/
Forum: https://forums.suse.com/forumdisplay.php?93-SUSE-Public-Cloud

Have a lot of fun...
ec2-user@hxehost:~>
```

You are now on the SAP HANA's machine. Type the following to change the hxeadm's password:

```
ec2-user@hxehost:~> sudo passwd hxeadm
New password:
```

Answer: **sys**

```
BAD PASSWORD: it is WAY too short
BAD PASSWORD: is a palindrome
Retype new password:
```

Don't bother with their warning about this being a bad password. Confirm it. :)

Now change to the **hxeadm** user: 

```
sudo su - hxeadm

##############################################################################
# Welcome to SAP HANA, express edition 2.0.                                  #
#                                                                            #
# The system must be configured before use.                                  #
##############################################################################


Password must be at least 8 characters in length.  It must contain at least
1 uppercase letter, 1 lowercase letter, and 1 number.  Special characters
are allowed, except \ (backslash), ' (single quote), " (double quotes),
` (backtick), and $ (dollar sign).

New HANA database master password:
```
It will immediatelly ask you for SAP HANA's master password. Answer: **SAPHANAPassword1**
This password is strong enough. It won't complain. When asked to confirm it, enter with it again.

```
Do you need to use proxy server to access the internet? (Y/N):
```
Answer: **N**
```
XSA configuration may take a while.  Do you wish to wait for XSA configuration to finish?
If you enter no, XSA will be configured in background after server completes.

Wait for XSA configuration to finish (Y/N) [Y] :
```
Answer: **Y**

```
##############################################################################
# Summary before execution                                                   #
##############################################################################
HANA, express edition
  Host name                            : hxehost
  Domain name                          : localdomain
  Master password                      : ********
  Log file                             : /var/tmp/hdb_init_config_2020-03-04_16.24.23.log
  Wait for XSA configuration to finish : Yes
  Proxy host                           : N/A
  Proxy port                           : N/A
  Hosts with no proxy                  : N/A

Proceed with configuration? (Y/N) :
```
Answer: **Y**

```
Please wait while HANA server starts.  This may take a while...
```
It will take about 7 minutes to finish. This is the last screen:
```
Free and used memory in the system
==================================
Before collection
-------------------------------------------------------------------------
             total       used       free     shared    buffers     cached
Mem:           29G        28G       1.0G        69M        25M        14G
-/+ buffers/cache:        13G        15G
Swap:         4.0G         0B       4.0G
After  collection
-------------------------------------------------------------------------
             total       used       free     shared    buffers     cached
Mem:           29G        28G       1.6G        69M        25M        14G
-/+ buffers/cache:        13G        16G
Swap:         4.0G         0B       4.0G



*** Congratulations! SAP HANA, express edition 2.0 is configured. ***
See https://www.sap.com/developer/tutorials/hxe-ua-getting-started-vm.html to get started.
```

## 7 - Deploy Speed Test for SAP HANA

Alright! SAP HANA is deployed and ready! Did you get its **EC2 Private IP**? It's EC2 private IP is its Endpoint. We can now run the script deployspeedtest.sh again to deploy SAP HANA:

```
/ICMDurable/Deployments/asamarySAPHANA # ./deployspeedtest.sh

Please, specify which speedtest you want to deploy. Available options are:

	 iris  - InterSystems IRIS

	 hana  - SAP HANA

	 aurora  - AWS Aurora

	 sqlserver  - AWS RDS SQL Server
```
Answer: **hana**

```
Enter with SAP HANA Express's end point:
```
Answer: **Enter with SAP HANA's EC2 Private IP address**

```
Enter with SAP HANA Express's username (SYSTEM):
```
Answer: **SYSTEM**


```
Enter with SAP HANA Express's password:
```
Answer: **SAPHANAPassword1**

The deployment will start. This should take less than 2 minutes to deploy and you should see at the end:
```
URL to SpeedTest | SAP HANA Express Speed Test is at:

	http://34.228.42.188

Done!
```
Now you have the URL for InterSystems IRIS Speed Test and the URL for SAP HANA's Speed Test! We are ready to make the comparison now!

## 8 - Comparing the Databases

Open both Speed Tests on your browser. Press the **Settings** button. Change the maximum time to run the speed test for 1200 seconds (20minutes).

Now just hit the **Run Test** button. If you get an error after pressing the Run Test button, try going back to the terminal and running the bouncespeedtest script:

```
/ICMDurable/Deployments/asamarySAPHANA # ./bouncespeedtest.sh
```

This will restart the containers for the Speed Test application for both InterSystems IRIS and SAP HANA. Try again and it should work.

After clicking on **Run Test**, it should immediately change to **Starting...**. For IRIS, this may take a long time since we are pre-expanding the database to its full capacity before starting the test (something that we would normally do on any production system). SAP HANA doesn't care too much about this since it is an **"In Memory"** database. IRIS is a hybrid database (In Memory performance with all the benefits of traditional databases). So IRIS still needs to have its disk database properly expanded. Just wait for it.

**Warning**: IRIS Database expansion can take a long time. We have given a lot of disk to IRIS so we can let the test running for more than 20min without filling up the disk. Just be patient. You may want to go to the InterSystems IRIS Management portal to check the expansion status.

Here are my results:

| Database                 | Machine   | Run time | Avg Inserts/s | Tot Records Inserted | Avg Queries/s | Tot Records Retrieved | Avg Query Response Time |
|--------------------------|-----------|----------|---------------|----------------------|---------------|-----------------------|-------------------------|
| InterSystems IRIS 2020.2 | i3.xlarge | 1200s    | 84,063rec/s   | 100,819,000          | 22,155rec/s   |  25,184,261           | 0.0432                  |
| SAP HANA Express 2.0     | i3.xlarge | 1200s    | 52,601rec/s   | 63,076,000           | 782.30rec/s   |  657,775              | 1.4451                  |

InterSystems IRIS:
-	Ingested 59.9% more records	
- Was ingesting them 59.9% faster in average
- Retrieved 2732.8% more records
- Was retrieving them 2732.1% faster in average

**ATEOT = At the end of Test. Or "sustained" rate.**

Both databases will start with excellent ingestion rates and then they will "degrade" to their **sustained performance**. SAP HANA start with an ingestion rate above 109K records/s, but it stabilized at the end of the test with an ingestion rate of ~57K rec/s with poor query responsiveness during the entire test. InterSystems IRIS suffered the same problem, but it was operating at ~79KK records/s ATEOT (37.61% faster) while maintaining much better query responsiveness during the entire test (3730% faster).

**The conclusion is that, on this ingestion x query stress test:**
* InterSystems IRIS is 37.61% faster than SAP HANA at ingestion
* InterSystems IRIS is 3730% faster than SAP HANA at querying

## 9 - Unprovision everything

We must first delete SAP HANA's EC2 machine. Use the EC2 dashboard for doing that. Wait for it to finish. SAP HANA is on our VPC. If we don't delete it first, we can't unprovision the Speed Test using ICM because we won't be able to delete that VPC (SAP HANA would be using it).

After SAP HANA is gone, proceed and run the unprovision.sh script:

```
/ICMDurable/Deployments/asamarySAPHANA # ./unprovision.sh
Warning: This will delete the existing configuration, including all persistent data volumes.
Type "yes" to confirm:
```
Answer: **yes**

ICM will now destroy all the machines, volumes and network configurations provisioned. This should take about 4 minutes.

After ICM is done, make sure you:
* Verify on EC2 Dashboard if all the instances under the label you used are gone
* Verify on EC2 Volumes if all the volumes under the label you used are gone 

## 10 - Screenshots

Here is the end result of SAP HANA's test:
![SAP HANA Results](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/ICM/DOC/SpeedTest_SAP_HANA_Express_2.0_i3.xlarge_results.png?raw=true)

Here is the end result of InterSystems IRIS test:
![InterSystems IRIS Results](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/ICM/DOC/SpeedTest_InterSystems_IRIS_2020.2_i3.xlarge_results.png?raw=true)