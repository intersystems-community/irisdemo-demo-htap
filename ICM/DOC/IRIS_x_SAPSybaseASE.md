# InterSystems IRIS x SAP Sybase ASE 16.0 SP03 PL08, public cloud edition, premium version

This document explains how to use the scripts we provide to quickly deploy the Speed Test against InterSystems IRIS and Sybase ASE. If you haven't done so yet, please follow instructions [here](../README.md) for the initial setup. There you will also find a diagram of how this is going to work.

I would suggest reading [this](https://help.sap.com/doc/c929440cdf914db1b5c3de3f32dbdba5/16.0.3.8/en-US/Quick_Start_Subscription_Premium.pdf) document prior to configuring Sybase on AWS. We will be using the cloud formation option for deploying SAP Sybase on our VPC. We will not be deploying it with HADR though.

# Provisioning the Initial environment on AWS

On this step, we will provision the initial environment on AWS which includes:
- All the machines for InterSystems IRIS, the InterSystems IRIS Speed Test and Sybase ASE Speed Test. 
- It will all be provisioned on the same VPC. 

Once we are done with the steps above, we will know our AWS VPC. We will use this information to manually deploy Sybase ASE on the same VPC later on.

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
Answer: **asamarySybaseASE**

I have picked asamarySybaseASE. You can pick a label of your choice.

````
Do you want InterSystems IRIS with Mirroring (answer yes or something else if not)?:**
````
Answer: **no**

We are deploying Sybase ASE without HADR. So we will deploy InterSystems IRIS in the same way.

```
How many Speed Test Masters do you want?:
```
Answer: **2**

```
How many Ingestion Workers per Master?:
```
Answer: **2**

```
How many Query Workers per Master?:
```
Answer: **2**

```
Please enter with the AWS instance type:
```
Answer: **I picked the option for "m5.2xlarge gp2 500 GB 1500 IOPS"**

```
Is this going to be a containerless installation of InterSystems IRIS (answer yes or something else if not)?:
```
Answer: **yes**

After this last question, you will see a message like:

```bash
ICM configured to provision m5.12xlarge machines on AWS.
You can now change to /ICMDurable/Deployments/asamarySybaseASE and run ./provision.sh to provision the infrastructure on AWS.
```
So, change to the folder that it is indicating:

```
/ICMDurable # cd ./Deployments/asamarySybaseASE/
```

## 3 - Provision

Run the provision.sh script. It will create the machines on AWS:

```
/ICMDurable/Deployments/asamarySybaseASE # ./provision.sh
```

It should take about 2 minutes to finish.

### ICM Provision Troubleshooting

If ICM is taking a long time to run, that is because something bad is happening. It will stop eventually and tell you what is wrong. But if you want to look right now what is wrong instead of waiting, you can look at the terraform.err file and see what is happening:

```
/ICMDurable/Deployments/asamarySybaseASE # cat ./state/asamarySybaseASE-IRISSpeedTest/terraform.err
```

Just replace "asamarySybaseASE" by the label you picked which happens to be the name of the folder you are.

Either way, you will see the error eventually. Here is a list of errors I encountered:
* **ExpiredToken**: The security token included in the request is expired": Your AWS credentials have expired and you need to get a new one. Repeat the step "Getting your AWS Credentials" and just run the ./provision.sh script again.
* **Error import KeyPair: InvalidKeyPair.Duplicate: The keypair '?' already exists.**: There is already a key called ? on EC2. Open EC2 on AWS, go to Key Pairs, find it and delete it.

It is normal to see some instances of "SSH operation failed" on the output. The machines are being provisioned by AWS and ICM keeps trying to SSH into them to continue with the setup process. If AWS hasn't finished provisioning the machines, we will get an SSH error. That is normal and ICM will just retry. Don't worry.

## 4 - Deploy InterSystems IRIS

Run the **deployiris.sh** script. It deploys InterSystems IRIS for you:

```
/ICMDurable/Deployments/asamarySybaseASE # ./deployiris.sh
```

This script will make ICM copy the InterSystems IRIS install kit to the machine on AWS and install it. So depending on your network, it may be very fast or take longer. On my PC, running from the office, it took 3 minutes.

When done, you will notice that ICM will write on the screen the URL for the management portal. Save that. You can open the management portal using the user **SuperUser** and the password **sys**. You will notice that there is a namespace called SPEEDTEST. This is where the speed test table will be created. You will be able to look at its contents during and after the speed test is run. 

## 5 - Deploy the Speed Test for InterSystems IRIS

Run the **deployspeedtest.sh** script:

```
/ICMDurable/Deployments/asamarySybaseASE # ./deployspeedtest.sh
```

It will present you a menu asking which speed test you want to deploy. Choose the option for InterSystems IRIS:

```
Please, specify which speedtest you want to deploy. Available options are:

   iris  - InterSystems IRIS

   hana  - Sybase ASE

   aurora  - Sybase ASE

   sqlserver  - AWS RDS SQL Server

   sybase - SAP Sybase ASE
```
Answer: **iris**

Deploying the Speed Test for InterSystems IRIS should take less then 2 minutes. You will see something like the following at the end:

```
URL to SpeedTest | InterSystems IRIS Speed Test is at:

	http://54.85.37.113

If you are planning on deploying Sybase ASE, Sybase ASE or any other AWS database, deploy them on the VPC_ID vpc-0e1734aabf07ddba1.

Done!
```

Please notice that we have just told you the **AWS VPC_ID**. Take note of that! When deploying Sybase ASE, you must deploy it on this VPC!

Also, take note of this URL we provided. It is the Speed Test UI for IRIS. Open it right now on a browser. On the SpeedTest UI that appears, press the **Settings** button. Change the maximum time to run the speed test for 5 seconds. Now just hit the **Run Test** button. It will take a long time to start since it is pre-expanding the database and we have configured a very big database for this test. Just leave it there. When it is finished expanding the database, it will run a 5 seconds test and automatically stop.

In the meanwhile, let's proceed with Sybase's instalation. 

## 6 - Deploy Sybase ASE

InterSystems IRIS and InterSystems IRIS Speed Test are deployed and you know the VPC_ID where they are. Here is what else we need to do:
* 6.1 - Manually deploy Sybase ASE on the same **VPC_ID**
* 6.2 - Take note of its **Endpoint**.

### 6.1 - Manually deploy Sybase ASE using CloudFormation

SAP provides a Cloud Formation template for deploying Sybase on AWS. This template provides a wizard-like UI that allows you to pick several options for the database including its instance type, the VPC where it must be deployed, super user password, defining the size of the data and log databases, etc. So let's get to it!

Click [here](https://aws.amazon.com/marketplace/pp/B07N927YMC?qid=1591830164991&sr=0-3&ref_=srh_res_product_title) to open SAP Sybase on AWS store. 

* Click on the yellow button **Continue to Subscribe** at the top left of the screen
* Click on the big yellow button **Accept Terms** at the center of the screen. Wait for your request to be processed. A table with the product name and the Effective Date of subscription will show **Pending** for a while and change to a subscription date when you are done. 
* Click on the yellow button **Continue to Configuration** at the top of the screen
* Chose **CloudFormation Template** as the Delivery Method and click on the yellow button **Continue to Launch** at the top of the screen
* Chose **Launch CloudFormation** under **Choose Action** combo box and click on **Launch**
* You will be taken to CloudFormation's create stack screen. Click on **Next**.
* Enter with a stack name. I used the same name I used on my label: **asamarySybaseASE**.
* Pick an Instance Type. In my case, I have picked **m5.2xlarge** (8 cores and 32GB of RAM). 
* Enter with the instance name. I used the same name I used on my label: **asamarySybaseASE**.
* Pick the right SSH key from the Key Name combo box. It will be something similar to **asamarySybaseASE-IRISSpeedTest**.
* Enter with **0.0.0.0/0** on SSH location. This is just a temporary instance we will destroy later so no need to pick a proper mask.
* Make sure you are picking the right VPC where to deploy. This would be something like **asamarySybaseASE-IRISSpeedTest**
* Make sure you are picking the right subnet where to deploy. This would be something like **asamarySybaseASE-IRISSpeedTest**
* You can name SAP ASE Server Name to be your label as well: **asamarySybaseASE**
* Set the master password to be **admin123**
* Set the user database name to be **SPEEDTEST**. 
* Set the User Database Data Device Size to 500 GB. This CloudFormation is going to deploy Sybase using gp2, which gives 3 IOPS per provisioned GB. So 500GB = 1500 IOPS. We are deploying IRIS database with gp2 and 1500IOPS as well. For some reason that I can't figure out, I can't give to Sybase's user database more than 1000 GB. If I do it, Sybase will not mount the volume and will let the database file and its log file on the root file system of the instance. That is why I am working with such a small instance. So I will give 500GB for the database and 1000GB for the database log (transaction journal file).
* Set the User Database Log Device Size to 1000 GB (=3000 IOPS). See observation above.
* Disable SAP ASE Configuration Auto Backup feature
* Under **SAP ASE Configuration - MemScale Option** we must configure:
  * Latch-Free Indexes: enable
  * Simplified Native Access Plan (SNAP): enable
  * Transactional Memory: enable
  * IMRS - DRC/MVCC/HCB: disable
  * IMRS - On-Disk MVCC: disable
  * IMDB database size: 0
  * IMDB database name: empty
* Click on **Next**.

SAP Sybase ASE in-memory technology is not the same as SAP HANA's in memory technology (or IRIS's in-memory caching). When using SAP Sybase ASE IMDB databases, data is NEVER persisted on disk. It is 100% in memory which is great for some use cases but it is not fully ACID like IRIS. So, in order to compare "apples to apples", do not configure IMDB. See more about SAP Sybase ASE IMDB [here](https://help.sap.com/viewer/a1237e466dba417da6f0e5504cf9fb83/16.0.3.3/en-US/abbe4beabc2b10149dafe7ac6d63d81d.html). That is why we are letting IMDB database size 0.

Now you can configure some options for this stack we are deploying. I have added a **Name** tag with the value **asamarySybaseASE**.

Click on **Next**. Review your configurations. Click on the checkbox to **"acknowledge that AWS CloudFormation might create IAM resources"** and proceed by clicking on the orange **Create Stack** button.

### 6.2 - Take note of Sybase ASE's Endpoint

After pressing the **Create Stack** button, you will be taken to the cloud formation stack page page for your new database. While Sybase ASE is being created you will notice the **CREATE_IN_PROGRESS** at the left of the screen under your stack's name (asamarySybaseASE, in my case). Wait for this status to change to **CREATE_COMPLETE**. It takes ~20 minutes. 

After this, go to your EC2 console and find Sybase ASE instance. Take note of its public and private IP addresses:
- The private IP address is the Endpoint you will use when deploying the speed test
- The public IP address is the one you use to open **Sybase ASE cockpit** and also to connect via **SSH** to the instance and use **isql**.

## 6.3 - Connecting to Sybase ASE instance using SSH

You can connect to Sybase ASE instance using its public IP address. The authentication is done using our private key. Here is the command:

```bash
ssh -i /ICMDurable/keys/insecure ec2-user@Sybase_Public_IP_Address
```

## 6.4 - Using isql to run queries

After connecting to the Sybase machine with SSH, you can use isql to run some SQL commands on Sybase if you are feeling like it. 

```bash
source /opt/sap/SYBASE.sh
./isql -Usa -Padmin123 -S[Sybase_Private_IP_Address]:5000
```

On the -S clause above, "127.0.0.1" or "localhost" won't work. You have to use the IP address.

## 6.5 - Verifying if our user databases have been correcly mounted

After connecting to the Sybase machine with SSH, run the following command:

```bash
[ec2-user@ip-10-0-1-81 ~]$ df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs         16G     0   16G   0% /dev
tmpfs            16G     0   16G   0% /dev/shm
tmpfs            16G   17M   16G   1% /run
tmpfs            16G     0   16G   0% /sys/fs/cgroup
/dev/nvme0n1p2   20G  5.4G   15G  27% /
/dev/nvme2n1    9.8G  3.3G  6.1G  35% /opt/sap
/dev/nvme4n1    9.8G  2.8G  6.6G  30% /ase/data/system_dbs
/dev/nvme3n1    492G  467G  9.9M 100% /ase/data/userdata_dbs
/dev/nvme1n1    984G  934G  7.0M 100% /ase/data/userlog_dbs
tmpfs           3.1G     0  3.1G   0% /run/user/1001
tmpfs           3.1G     0  3.1G   0% /run/user/1000
```

You should see two file systems mounted with the sizes we requested:
- /ase/data/userdata_dbs - Where our SPEEDTEST user database file is
- /ase/data/userlog_dbs - Where our SPEEDTEST user database log file is

Take note of how much space is available on these two file systems. If you are doing this right after you have provisioned Sybase, you will notice that there will be plenty of space available on both file systems. It seems that Sybase automatically starts pre-expanding the log and database files on these file systems and that this process takes a lot of CPU. If your file systems are still bellow 100% use, you can run a **top** command to check that your CPU will be at 100%. We should wait Sybase finish this before running our test just like we are waiting for IRIS to pre-expand its database file.

On the other hand, if you don't see these two file systems, that is because you probably tried to give your user database or log file more space than we are suggesting on this guide. As I explained above, I don't know why, when the volumes are bigger, Sybase will not mount the provisioned filesystems and put our database file and log file there. 

If you are having this problem, you may want to look into this log to see what happened:

```bash
cat /ase/aws/mkfs_mount.out
```

Not sure it is going to help, though. Try to stick to the suggested sizes on this guide and you should be fine.

## 6.6 - Using Sybase ASE Cockpit

Sybase ASE provides a management portal that will be at:

https://[Sybase ASE public IP address]:4283/cockpit

You can use the username "sa" and password "admin123" that we have configured before. I had to open this on Firefox because the portal is an Adobe Flash application and my Safari didn't support it. 

It is useful because it gives you some statistics about CPU usage, disk usage, locks and contention. It is a nice thing to look while you are running the test.

The overview page will immediatelly show you CPU usage. You will notice that since Sybase started, it has been using 100% of the CPU. My CPU usage immediately dropped after both file systems were 100% full (both the database and the log file were 100% expanded).

## 7 - Deploy Speed Test for Sybase ASE

Alright! Sybase ASE is deployed and ready! Did you get its **End point** (private IP address)? We can now run the script **deployspeedtest.sh** again to deploy the speed test version for Sybase ASE:

```
/ICMDurable/Deployments/asamarySybaseASE # ./deployspeedtest.sh

Please, specify which speedtest you want to deploy. Available options are:

	 iris  - InterSystems IRIS

	 hana  - Sybase ASE

	 aurora  - Sybase ASE

	 mssqlserver  - AWS RDS Sybase ASE

	 sybase  - SAP Sybase ASE
```
Answer: **sybase**

```
Enter with Sybase ASE's WRITER end point:
```
Answer: **Enter with Sybase ASE's end point. It's EC2 private IP address.**

```
Enter with Sybase ASE's username (sa):
```
Answer: **sa**


```
Enter with Sybase ASE's password:
```
Answer: **admin123**

The deployment will start. This should take less than 2 minutes to deploy and you should see at the end:
```
URL to SpeedTest | Sybase ASE Speed Test is at:

	http://34.228.42.188

Done!
```

Now you have the URL for InterSystems IRIS Speed Test and the URL for Sybase ASE's Speed Test! We are ready to make the comparison now!

## 8 - Comparing the Databases

Open both Speed Tests on your browser. Press the **Settings** button. Change the maximum time to run the speed test for 1200 seconds (20minutes).

Now just hit the **Run Test** button. If you get an error after pressing the Run Test button, try going back to the terminal and running the bouncespeedtest script:

```
/ICMDurable/Deployments/asamarySybaseASE # ./bouncespeedtest.sh
```

This will restart the containers for the Speed Test application for both InterSystems IRIS and Sybase. Try again and it should work. 

After clicking on **Run Test**, it should immediately change to **Starting...**. For IRIS, this may take a long time since we are pre-expanding the database to its full capacity before starting the test (something that we would normally do on any production system). IRIS is a hybrid database (In Memory performance with all the benefits of traditional databases). So IRIS still needs to have its disk database properly expanded. Just wait for it. We could not find a way of doing the same for Sybase ASE, so what we did was to run the Speed Test once on Sybase ASE to "warm it up". Then we did the actual test against IRIS.

**Warning**: IRIS Database expansion can take a long time. We have given a lot of disk to IRIS so we can let the test running for more than 20min without filling up the disk. Just be patient. You may want to go to the InterSystems IRIS Management portal to check the expansion status.

**If you needed to run the bounce speed test script, make sure you reconfigure the maximum time for running the test above again.**

After 20 minutes, here are my initial results running on a m5.2xlarge (8 cores and 16Gb of RAM):

| Database                           | Machine    | Run time | Avg Inserts/s  | Tot Records Inserted | Avg Queries/s    | Tot Records Retrieved AEOT | Query Response Time AEOT | CPU utilization |
|------------------------------------|------------|----------|----------------|----------------------|------------------|----------------------------|--------------------------|-----------------|
| InterSystems IRIS 2020.2           | m5.2xlarge | 1200s    | 223,151rec/sec | 267,740,000          | 30,091.71rec/sec | 36,133,102.00              | 0.0327ms                 | 70% |
| AWS RDS Sybase ASE 16.0 SP03 PL08  | m5.2xlarge | 1200s    |   4,499rec/sec | 5,395,000            | 891.08rec/sec    | 1,068,405.00               | 1.8832ms                 | 100% |

InterSystems IRIS:					
- Ingested 4862.8% more records
- Was ingesting them 6733.4% faster AEOT
- Retrieved 3282% more records
- Was retrieving them 5654.6% faster AEOT

## 9 - Unprovision everything

We must first delete Sybase ASE's. Wait for it to finish. Sybase ASE is on our VPC. If we don't delete it first, we can't unprovision the Speed Test using ICM because we won't be able to delete that VPC (Sybase ASE would be using it).

After Sybase ASE is gone, proceed and run the unprovision.sh script:

```
/ICMDurable/Deployments/asamarySybaseASE # ./unprovision.sh
Warning: This will delete the existing configuration, including all persistent data volumes.
Type "yes" to confirm:
```
Answer: **yes**

ICM will now destroy all the machines, volumes and network configurations provisioned. This should take about 4 minutes.

After ICM is done, make sure you:
* Verify on EC2 Dashboard if all the instances under the label you used are gone
* Verify on EC2 Volumes if all the volumes under the label you used are gone 

## 10 - Screenshots

Here is the end result of Sybase ASE's test:
![Sybase ASE Results](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/ICM/DOC/SpeedTest_AWS_SAP_Sybase_ASE_Enterprise_on_m2xlarge_gp2_500GB_1500_IOPS_results.png?raw=true)

Here is the end result of InterSystems IRIS test:
![InterSystems IRIS Results](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/master/ICM/DOC/SpeedTest_InterSystems_IRIS_on_m2xlarge_gp2_500GB_1500_IOPS_results.png?raw=true)