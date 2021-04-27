# InterSystems IRIS x SQL Server Enterprise 2017 on AWS

This document explains how to use the scripts we provide to quickly deploy the Speed Test against InterSystems IRIS and SQL Server. If you haven't done so yet, please follow instructions [here](../README.md) for the initial setup. There you will also find a diagram of how this is going to work.

# Provisioning the Initial environment on AWS

On this step, we will provision the initial environment on AWS which includes:
- All the machines for InterSystems IRIS, the InterSystems IRIS Speed Test and AWS RDS Aurora Speed Test. 
- It will all be provisioned on the same VPC. 

Once we are done with the steps above, we will know our AWS VPC. We will use this information to manually deploy SQL Server on the same VPC later on.

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
Answer: **asamaryAWSSQLServer**

````
Do you want InterSystems IRIS with Mirroring (answer yes or something else if not)?:**
````
Answer: **yes**

SQL Server is deployed with replication between two availability zones. So we will deploy InterSystems IRIS in the same way.

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
Answer: **Pick the option for m5.xlarge**

```
Is this going to be a containerless installation of InterSystems IRIS (answer yes or something else if not)?:
```
Answer: **yes**

After this last question, you will see a message like:

```bash
ICM configured to provision m5.xlarge machines on AWS.
You can now change to /ICMDurable/Deployments/asamaryAWSSQLServer and run ./provision.sh to provision the infrastructure on AWS.
```
So, change to the folder that it is indicating:

```
/ICMDurable # cd ./Deployments/asamaryAWSSQLServer/
```

## 3 - Provision

Run the provision.sh script. It will create the machines on AWS:

```
/ICMDurable/Deployments/asamaryAWSSQLServer # ./provision.sh
```

It should take about 2 minutes to finish.

### ICM Provision Troubleshooting

If ICM is taking a long time to run, that is because something bad is happening. It will stop eventually and tell you what is wrong. But if you want to look right now what is wrong instead of waiting, you can look at the terraform.err file and see what is happening:

```
/ICMDurable/Deployments/asamaryAWSSQLServer # cat ./state/asamaryAWSSQLServer-IRISSpeedTest/terraform.err
```

Just replace "asamaryAWSSQLServer" by the label you picked which happens to be the name of the folder you are.

Either way, you will see the error eventually. Here is a list of errors I encountered:
* **ExpiredToken**: The security token included in the request is expired": Your AWS credentials have expired and you need to get a new one. Repeat the step "Getting your AWS Credentials" and just run the ./provision.sh script again.
* **Error import KeyPair: InvalidKeyPair.Duplicate: The keypair '?' already exists.**: There is already a key called ? on EC2. Open EC2 on AWS, go to Key Pairs, find it and delete it.

It is normal to see some instances of "SSH operation failed" on the output. The machines are being provisioned by AWS and ICM keeps trying to SSH into them to continue with the setup process. If AWS hasn't finished provisioning the machines, we will get an SSH error. That is normal and ICM will just retry. Don't worry.

## 4 - Deploy InterSystems IRIS

Run the **deployiris.sh** script. It deploys InterSystems IRIS for you:

```
/ICMDurable/Deployments/asamaryAWSSQLServer # ./deployiris.sh
```

This script will make ICM copy the InterSystems IRIS install kit to the machine on AWS and install it. So depending on your network, it may be very fast or take longer. On my PC, running from the office, it took 3 minutes.

When done, you will notice that ICM will write on the screen the URL for the management portal. Save that. You can open the management portal using the user **SuperUser** and the password **sys**. You will notice that there is a namespace called SPEEDTEST. This is where the speed test table will be created. You will be able to look at its contents during and after the speed test is run. 

## 5 - Deploy the Speed Test for InterSystems IRIS

Run the **deployspeedtest.sh** script:

```
/ICMDurable/Deployments/asamaryAWSSQLServer # ./deployspeedtest.sh
```

It will present you a menu asking which speed test you want to deploy. Choose the option for InterSystems IRIS:

```
Please, specify which speedtest you want to deploy. Available options are:

	 iris  - InterSystems IRIS

	 hana  - SQL Server

	 aurora  - SQL Server

	 sqlserver  - AWS RDS SQL Server
```
Answer: **iris**

Deploying the Speed Test for InterSystems IRIS should take less then 2 minutes. You will see something like the following at the end:

```
URL to SpeedTest | InterSystems IRIS Speed Test is at:

	http://54.85.37.113

If you are planning on deploying SQL Server, SQL Server or any other AWS database, deploy them on the VPC_ID vpc-0e1734aabf07ddba1.

Done!
```

Take note of this URL! You can open it right now and you should be able to click at the **Run Test** button to run the speed test against InterSystems IRIS for the first time. Please, click on the button only one and wait. It takes a couple of seconds to start populating the screen with results.

You can leave it running for 5 minutes or so. It will pre-expand the InterSystems IRIS database for us. So when we run it again to compare against SQL Server, the database will be pre-expanded as in any production system.

Also, please note that we have just told you the **AWS VPC_ID**. Take note of that! When deploying SQL Server, you must deploy it on this VPC!

## 6 - Deploy SQL Server 2.0 Express Edition

InterSystems IRIS and InterSystems IRIS Speed Test are deployed and you know the VPC_ID where they are. Here is what else we need to do:
* 6.1 - Manually deploy SQL Server on the same **VPC_ID**
* 6.2 - Take note of its **Endpoint**.

### 6.1 - Manually deploy SQL Server

Click [here](https://console.aws.amazon.com/rds/home?region=us-east-1#) to open AWS RDS. 

* Click on the button **Create Database**
* At "Choose a database creation method", pick option **Standard Create**
* Under "Engine options":
  * At "Engine type" pick option **Microsoft SQL Server**
  * At "Edition" pick option **SQL Server Enterprise Edition**
  * At "Version" pick **2017**
  * At "Database Location" pick option **Regional**
* Under Templates, chose **Production**
* Under "Settings":
  * At "DB instance identifier" enter with **speedtest**
  * At "Credential Settings" leave "Master username" as **admin** and set the password to **admin123**
* At "DB instance size", pick **db.m5.xlarge** 
* At Storage:
  * Leave Storage Type set to **Provisioned IOPS (SSD)**
  * Set Allocated Storage to **500GiB** - That is required for the size of the database (100), plus log (journal) files (3x100). We also want to leave some space left (100).
  * Set Provisioned IOPS to **2500**
  * Disable Storage Autoscaling
* At "Availability & durability" leave it as **Yes (Mirroring / Always On)**
* Under "Connectivity":
  * At "Virtual Private Cloud (VPC)", pick the VPC_ID created for us on the previous steps
  * Under Additional Connectivity Configuration:
    * At "Subnet group", leave it with **Create new DB subnet Group**
    * At "Publicly accessible", leave it with **No**
    * At "VPC security group", leave it with **Choose existing** and pick the one named **YourLabel-VM-IRISSpeedTestext**
* Do not enable Microsoft SQL Server Windows Authentication
* Under "Additional Configuration":
  * Set Backup Retention Period to 1 day
  * Disable Encryption
  * Disable Performance Insights
  * Disable Enhanced Monitoring
  * Disable deletion protection
* Click on **Create Database**

### 6.2 - Take note of SQL Server's Endpoint

After pressing the **Create Database** button, you will be taken to the management page for your new database. While SQL Server is being created you will notice the **Creating** status appearing at the side of its main identifier: **speedtest**.

Be patient. SQL Server takes about half an hour or so to deploy!

When it is created, click on its identifier so we can see its endpoints. It should have two endpoints lised. Pick the **listener** one. It is a string that looks like this: "listener.speedtest.c9amfj7kmxqv.us-east-1.rds.amazonaws.com".

## 7 - Deploy Speed Test for SQL Server

Alright! SQL Server is deployed and ready! Did you get its **End point**? We can now run the script deployspeedtest.sh again to deploy SQL Server:

```
/ICMDurable/Deployments/asamaryAWSSQLServer # ./deployspeedtest.sh

Please, specify which speedtest you want to deploy. Available options are:

	 iris  - InterSystems IRIS

	 hana  - SQL Server

	 aurora  - SQL Server

	 mssqlserver  - AWS RDS SQL Server
```
Answer: **mssqlserver**

```
Enter with SQL Server Express's WRITER end point:
```
Answer: **Enter with Enter with SQL Server's end point:**

```
Enter with SQL Server's username (admin):
```
Answer: **admin**


```
Enter with SQL Server's password:
```
Answer: **admin123**

The deployment will start. This should take less than 2 minutes to deploy and you should see at the end:
```
URL to SpeedTest | SQL Server Speed Test is at:

	http://34.228.42.188

Done!
```

Now you have the URL for InterSystems IRIS Speed Test and the URL for SQL Server's Speed Test! We are ready to make the comparison now!

## 8 - Comparing the Databases

Open both Speed Tests on your browser. Press the **Settings** button. Change the maximum time to run the speed test for 1200 seconds (20minutes).

Now just hit the **Run Test** button. If you get an error after pressing the Run Test button, try going back to the terminal and running the bouncespeedtest script:

```
/ICMDurable/Deployments/asamaryAWSSQLServer # ./bouncespeedtest.sh
```

This will restart the containers for the Speed Test application for both InterSystems IRIS and Aurora. Try again and it should work. 

After clicking on **Run Test**, it should immediately change to **Starting...**. For InterSystems IRIS, this may take a long time since we are pre-expanding the database to its full capacity before starting the test (something that we would normally do on any production system). InterSystems IRIS is a hybrid database (In Memory performance with all the benefits of traditional databases). So InterSystems IRIS still needs to have its disk database properly expanded. Just wait for it. We could not find a way of doing the same for SQL Server, so what we did was to run the Speed Test once on SQL Server to "warm it up". Then we did the actual test against InterSystems IRIS.

**Warning**: InterSystems IRIS Database expansion can take a long time. We have given a lot of disk to InterSystems IRIS so we can let the test running for more than 20min without filling up the disk. Just be patient. You may want to go to the InterSystems IRIS Management portal to check the expansion status.

**If you needed to run the bounce speed test script, make sure you reconfigure the maximum time for running the test above again.**

After 20 minutes, here are my initial results running on a m5.xlarge (16Gb of RAM):

| Database                 | Machine       | Run time | Avg Inserts/s       | Tot Records Inserted | Avg Queries/s       | Tot Records Retrieved AEOT | Query Response Time AEOT     | 
|--------------------------|---------------|----------|---------------------|----------------------|---------------------|----------------------------|------------------------------|
| InterSystems IRIS 2020.2 | m5.xlarge     | 1200s    | 134,173K rec/sec    | 160,911,000          | 21,928 rec/sec      | 26,297,327                 | 0.0459ms                     |
| AWS RDS SQL Server 2017  | db.m5.xlarge  | 1200s    | Can't publish     | Can't publish           | Can't publish        | Can't publish                        | Can't publish |


The results were astounding but we can't publish them because SQL Server's EULSA prevents us from doing it. But you can run the test yourself and find out! :)

## 9 - Unprovision everything

We must first delete SQL Server's. Wait for it to finish. SQL Server is on our VPC. If we don't delete it first, we can't unprovision the Speed Test using ICM because we won't be able to delete that VPC (SQL Server would be using it).

After SQL Server is gone, proceed and run the unprovision.sh script:

```
/ICMDurable/Deployments/asamaryAWSSQLServer # ./unprovision.sh
Warning: This will delete the existing configuration, including all persistent data volumes.
Type "yes" to confirm:
```
Answer: **yes**

ICM will now destroy all the machines, volumes and network configurations provisioned. This should take about 4 minutes.

After ICM is done, make sure you:
* Verify on EC2 Dashboard if all the instances under the label you used are gone
* Verify on EC2 Volumes if all the volumes under the label you used are gone 

## 10 - Screenshots

The results were astounding but we can't publish them because SQL Server's EULSA prevents us from doing it. But you can run the test yourself and find out! :)