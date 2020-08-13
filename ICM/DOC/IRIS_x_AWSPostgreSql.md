# InterSystems IRIS x AWS RDS PostgreSQL 12.3

This document explains how to use the scripts we provide to quickly deploy the Speed Test against InterSystems IRIS and PostgreSQL running on AWS. If you haven't done so yet, please follow instructions [here](../README.md) for the initial setup. There you will also find a diagram of how this is going to work.

# Provisioning the Initial environment on AWS

On this step, we will provision the initial environment on AWS which includes:
- All the machines for InterSystems IRIS, the InterSystems IRIS Speed Test and AWS RDS PostgreSQL Speed Test. 
- It will all be provisioned on the same VPC. 

Once we are done with the steps above, we will know our AWS VPC. We will use this information to manually deploy Postgres on the same VPC later on.

## 1 - Start ICM

You have clonned this repo to a folder on your PC. Now, open a terminal and change to the ICM folder. Run the downloadicm.sh script to get the InterSystems ICM image on your machine.

```bash
./downloadicm.sh
```

Run the icm.sh script to start the icm container:

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
Answer: **asamaryPostgreSQL**

````
Do you want InterSystems IRIS with Mirroring (answer yes or something else if not)?:**
````
Answer: **yes**

Postgres is deployed with replication between two availability zones. So we will deploy InterSystems IRIS in the same way.

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
Answer: **Pick the option for m5.2xlarge io1 500 GB 2500 IOPS** 

After this last question, you will see a message like:

```bash
ICM configured to provision m5.2xlarge machines on AWS.
You can now change to /ICMDurable/Deployments/asamaryPostgreSQL and run ./provision.sh to provision the infrastructure on AWS.
```
So, change to the folder that it is indicating:

```
/ICMDurable # cd ./Deployments/asamaryPostgreSQL/
```

## 3 - Provision

Run the provision.sh script. It will create the machines on AWS:

```
/ICMDurable/Deployments/asamaryPostgreSQL # ./provision.sh
```

It should take about 2 minutes to finish.

### ICM Provision Troubleshooting

If ICM is taking a long time to run, that is because something bad is happening. It will stop eventually and tell you what is wrong. But if you want to look right now what is wrong instead of waiting, you can look at the terraform.err file and see what is happening:

```
/ICMDurable/Deployments/asamaryPostgreSQL # cat ./state/asamaryAuroraMySQL-IRISSpeedTest/terraform.err
```

Just replace "asamaryPostgreSQL" by the label you picked which happens to be the name of the folder you are.

Either way, you will see the error eventually. Here is a list of errors I encountered:
* **ExpiredToken**: The security token included in the request is expired": Your AWS credentials have expired and you need to get a new one. Repeat the step "Getting your AWS Credentials" and just run the ./provision.sh script again.
* **Error import KeyPair: InvalidKeyPair.Duplicate: The keypair '?' already exists.**: There is already a key called ? on EC2. Open EC2 on AWS, go to Key Pairs, find it and delete it.

It is normal to see some instances of "SSH operation failed" on the output. The machines are being provisioned by AWS and ICM keeps trying to SSH into them to continue with the setup process. If AWS hasn't finished provisioning the machines, we will get an SSH error. That is normal and ICM will just retry. Don't worry.

## 4 - Deploy InterSystems IRIS

Run the **deployiris.sh** script. It deploys InterSystems IRIS for you:

```
/ICMDurable/Deployments/asamaryPostgreSQL # ./deployiris.sh
```

This script will make ICM copy the InterSystems IRIS install kit to the machine on AWS and install it. So depending on your network, it may be very fast or take longer. On my PC, running from the office, it took 3 minutes.

When done, you will notice that ICM will write on the screen the URL for the management portal. Save that. You can open the management portal using the user **SuperUser** and the password **sys**. You will notice that there is a namespace called SPEEDTEST. This is where the speed test table will be created. You will be able to look at its contents during and after the speed test is run. 

## 5 - Deploy the Speed Test for InterSystems IRIS

Run the **deployspeedtest.sh** script:

```
/ICMDurable/Deployments/asamaryPostgreSQL # ./deployspeedtest.sh
```

It will present you a menu asking which speed test you want to deploy. Choose the option for InterSystems IRIS:

```
Please, specify which speedtest you want to deploy. Available options are:

	 iris  - InterSystems IRIS

	 hana  - AWS Aurora

	 aurora  - AWS Aurora

	 sqlserver  - AWS RDS SQL Server

   postgres - AWS RDS PostgreSQL
```
Answer: **iris**

Deploying the Speed Test for InterSystems IRIS should take less then 2 minutes. You will see something like the following at the end:

```
URL to SpeedTest | InterSystems IRIS Speed Test is at:

	http://54.85.37.113

If you are planning on deploying AWS Aurora, AWS Aurora or any other AWS database, deploy them on the VPC_ID vpc-0e1734aabf07ddba1.

Done!
```

Take note of this URL! You can open it right now and you should be able to click at the **Run Test** button to run the speed test against InterSystems IRIS for the first time. Please, click on the button only one and wait. It takes a couple of seconds to start populating the screen with results.

You can leave it running for 5 minutes or so. It will pre-expand the InterSystems IRIS database for us. So when we run it again to compare against AWS RDS PostgreSQL, the database will be pre-expanded as in any production system.

Also, please note that we have just told you the **AWS VPC_ID**. Take note of that! When deploying AWS RDS PostgreSQL, you must deploy it on this VPC!

## 6 - Deploy AWS RDS PostgreSQL 

InterSystems IRIS and InterSystems IRIS Speed Test are deployed and you know the VPC_ID where they are. Here is what else we need to do:
* 6.1- Manually deploy AWS RDS PostgreSQL on the same **VPC_ID**
* 6.2- Take note of its **Endpoint**.

### 6.1 - Manually deploy AWS PostgreSQL

Click [here](https://console.aws.amazon.com/rds/home?region=us-east-1#) to open AWS RDS. 

* Click on the button **Create Database**
* At "Choose a database creation method", pick option **Standard Create**
* Under "Engine options":
  * At "Engine type" pick option **PostgreSQL**
  * At "Version" pick option **PostgreSQL 12.3-R1**
  * At "Templates" pick option **Production**
* Under "Settings":
  * At "DB instance identifier" enter with **speedtest**
  * At "Credential Settings" leave "Master username" as **postgresuser** and set the password to **postgrespass**
* Under "DB instance size":
  * Pick Standard classes
  * pick **db.m5.2xlarge** (careful: don't take db.r5.large by mistake!)
  * At "Credential Settings" leave "Master username" as **postgresuser** and set the password to **postgrespass**
* Under "Storage":
  * At "Storage Type" pick Provisioned IOPS (SSD)
  * At "Allocated Storage" pick 500 GiB
  * At "Provisioned IOPS" pick 2500
  * Leave "Enabled storage autoscaling" selected
* Under "Availability & durability":
  * Leave "Create a standby instance" Selected. We are simulating a production deployment and we are running IRIS with mirroring as well so this is comparable.
* Under "Connectivity":
  * At "Virtual Private Cloud (VPC)", pick the VPC_ID created for us on the previous steps
  * Select the "Additional connectivity configuration" dropdown
  * At "Subnet group", it should be populated with the default subnet group for you VPC
  * At "Publicly accessible", leave it with **No**
  * At "VPC security group", leave it with **Choose existing** and pick the one named **YourLabel-CN-IRISSpeedTestext**. If you don't see any VPC security groups then you need to double check and make sure you have in fact selected the correct VPC. If that is correct then you are experiencing an AWS bug. The bug hides your VPC security groups since this is the first time you are creating a DB in the VPC. In order to get around this bug you need to create a dummy DB and add it into your VPC. You can delete this DB right after creating it, but after its creation you will be able to add the VPC security group to any new databases you create.
* At "Database authentication" leave it with **Password authentication**
* Under "Additional Configuration":
  * Set "Initial database name" with **SPEEDTEST**
  * Disable automatic Backups
  * Disable Encryption
  * Disable Performance Insights
  * Disable Enhanced Monitoring
  * Disable deletion protection
* Click on **Create Database**

### 6.2 - Take note of AWS RDS PostgreSQL's Endpoint

After pressing the **Create Database** button, you will be taken to the management page for your new database. While AWS Postgres is being created you can click on its main identifier (**speedtest**) and look for its endpoints. 

## 7 - Deploy Speed Test for AWS PostgreSQL

Alright! AWS RDS PostgreSQL is deployed and ready! Did you get its **End point**? We can now run the script deployspeedtest.sh again to deploy AWS PostgreSQL:

```
/ICMDurable/Deployments/asamaryAuroraMySQL # ./deployspeedtest.sh

Please, specify which speedtest you want to deploy. Available options are:

	 iris  - InterSystems IRIS

	 hana  - AWS Aurora

	 aurora  - AWS Aurora

	 sqlserver  - AWS RDS SQL Server

   postgres - AWS RDS PostgreSQL
```
Answer: **postgres**

Answer: **Enter with AWS RDS Postgres's end point:**

```
Enter with AWS PostgreSQL's username (postgresuser):
```
Answer: **postgresuser**


```
Enter with AWS PostgreSQL's password:
```
Answer: **postgrespass**

The deployment will start. This should take less than 2 minutes to deploy and you should see at the end:
```
URL to SpeedTest | AWS PostgreSQL Speed Test is at:

	http://34.228.42.188

Done!
```
We are ready to make the comparison now!

## 8 - Comparing the Databases

Open both Speed Tests on your browser. Press the **Settings** button. Change the maximum time to run the speed test for 1200 seconds (20minutes).

Now just hit the **Run Test** button. If you get an error after pressing the Run Test button, try going back to the terminal and running the bouncespeedtest script:

```
/ICMDurable/Deployments/asamaryPostgreSQL # ./bouncespeedtest.sh
```

This will restart the containers for the Speed Test application for both InterSystems IRIS and PostgreSQL. Try again and it should work. 

After clicking on **Run Test**, it should immediately change to **Starting...**. For InterSystems IRIS, this may take a long time since we are pre-expanding the database to its full capacity before starting the test (something that we would normally do on any production system). InterSystems IRIS is a hybrid database (In Memory performance with all the benefits of traditional databases). So InterSystems IRIS still needs to have its disk database properly expanded. Just wait for it. We could not find a way of doing the same for AWS RDS Postgres, so what we did was to run the Speed Test once on AWS RDS Postgres to "warm it up". Then we did the actual test against InterSystems IRIS.

**Warning**: InterSystems IRIS Database expansion can take a long time. We have given a lot of disk to InterSystems IRIS so we can let the test running for more than 20min without filling up the disk. Just be patient. You may want to go to the InterSystems IRIS Management portal to check the expansion status.

**If you needed to run the bounce speed test script, make sure you reconfigure the maximum time for running the test above again.**

### Results

After 20 minutes, here are my results when using AWS RDS PostgreSQL:


| Database                         | Machine      | Run time | Avg Inserts/s       | Tot Records Inserted | Avg Queries/s       | Tot Records Retrieved AEOT | Query Response Time AEOT |
|----------------------------------|--------------|----------|---------------------|----------------------|---------------------|----------------------------|------------------------------|
| InterSystems IRIS 2020.2         | m5.2xlarge   | 1200s    | 227K rec/sec     | 272,854,000 | 28,061 rec/sec | 33,651,203          | 0.0353ms                   |
| AWS RDS PostgreSQL | db.m5.2xlarge | 1200s    | 108K rec/sec   | 129,855,000 | 4,052 rec/sec | 4,858,530        | 0.2886ms                |

InterSystems IRIS:					
- Ingested 110.2% more records	
- Was ingesting them 108.2% faster
- Retrieved 592.7% more records	
- Was retrieving them 718% faster

## 9 - Unprovision everything

We must first delete the Postgres Database. Wait for it to finish. Postgres is on our VPC. If we don't delete it first, we can't unprovision the Speed Test using ICM because we won't be able to delete that VPC (Postgres would be using it).

After Postgres is gone, proceed and run the unprovision.sh script:

```
/ICMDurable/Deployments/asamaryPostgreSQL # ./unprovision.sh
Warning: This will delete the existing configuration, including all persistent data volumes.
Type "yes" to confirm:
```
Answer: **yes**

ICM will now destroy all the machines, volumes and network configurations provisioned. This should take about 4 minutes.

After ICM is done, make sure you:
* Verify on EC2 Dashboard if all the instances under the label you used are gone
* Verify on EC2 Volumes if all the volumes under the label you used are gone 

## 10 - Screenshots

Here is the end result of AWS RDS PostgreSQL's test:
![AWS RDS PostgreSQL Results](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/adding-postgresql/ICM/DOC/SpeedTest_AWS_RDS_PostgreSQL_results.png?raw=true)

Here is the end result of InterSystems IRIS test:
![InterSystems IRIS Results](https://raw.githubusercontent.com/intersystems-community/irisdemo-demo-htap/adding-postgresql/ICM/DOC/SpeedTest_Intersystems_IRIS_2020.2_on_m2xlarge_oi1_500GB_2500_IOPS_results.png?raw=true)