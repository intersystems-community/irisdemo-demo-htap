# Using ICM with AWS

This folder has scripts that are written to make using ICM with AWS very easy.

First, you open a terminal and run the icm.sh script to start the icm container.

Then, from inside the ICM container, you change to the directory /ICMDurable:

```bash
cd /ICMDurable
```

Then, there will be the following scripts available:
* **setup.sh** - Use this script to set ICM up. 
* **provision.sh** - Provision the infrastructure for IRIS, IRIS Speed Test, and Other database Speed Test (if more than one master is entered). We are still working on making it possible running the Speed Test against SAP HANA and other databases on AWS.
* **deployiris.sh** - Deploy IRIS to the provisioned infrastructure.
* **deployspeedtest.sh** - Deploy the speed test for IRIS and other supported databases.
* **unprovision.sh** - Unprovision the entire infrastructure on AWS.

## Setup

Run the setup.sh script and answer the questions. 
 * Confirm that you want to run the script by typing "yes" and ENTER. 
 * Then enter with a label for all your machines (please, pick something different from asamary!
 * You will be asked about how many masters do you want. These are not "IRIS Data Masters". The HTAP Demo has a master that coordinates the work with the workers. The UI talks to the Master and the Master talks to the workers. So, if you are running the speed test against IRIS, you need one Master. If you are running the speed test against IRIS and another database, you need two masters. So, answer accordingly:
   - 1 - if you are running a speed test against IRIS only
   - 2 - if you are running a speed test against IRIS and another database (such as SAP HANA)
 * When asked about how many ingestion workers, enter with a number greater than 1. Start with 1 if this is your first speed test. If you have more than one master and you have asked for 1 ingestion worker, you will end up with 1 ingestion worker per master (2 ingestion workers).
 * When asked about how many query workers, enter with 1. Start with 1 if this is your first speed test.
 * When asked about the AWS instance, enter with:
   - 1: for comparing against SAP HANA Express 32Gb (m4-2xlarge)
   - 2: for a bigger m5 box
 * Enter with your docker hub user name (so ICM will be able to download the HTAP Demo images and the IRIS images from docker hub).
 * Enter with your docker hub password.
 * When asked if you want IRIS with mirroring, answer "no" and ENTER. SAP HANA Express doesn't have replication.

It will generate:
* defaults.json - This includes everything about IRIS and your docker hub credentials
* definitions.json - This includes the infrastructure configuration we want
* merge.cpf - This will include instance configurations such as global buffers, memory heap, etc.
* aws.credentials - This file is for you to paste your AWS credentials so that ICM can provision the infrastructure

The next step are:
* Go to AWS and copy your credentials and paste it on file aws.credentials. (look at the aws.credentials file for an example on what this looks like)
* Save your iris.key file to the ./ICMDurable/license/ folder.

Finally, look inside the file **base_env.sh**. You will see two lines like this:

```bash
export IRIS_TAG=2019.3.0.309.0
export IRIS_PRIVATE_REPO=amirsamary/irisdemo
```

This is where we are going to pull our IRIS image from. Make sure you have access to this repository (if you are a customer, I can give it to you) or change it to point to:
- Your own IRIS image on your own Docker Repository
- InterSystems Official Docker Store Repository (you need to be a customer for this)

Now you are ready to provision the Infrastructure!

## Provision

Run the provision.sh script. It will create the machines on AWS.

### ICM Provision Troubleshooting

If ICM is taking a long time to run, that is because something bad is happening. It will stop eventually and tell you what is wrong. But if you want to look right now what is wrong instead of waiting, you can look at the terraform.err file and see what is happening:

```
/ICMDurable # cat ./State/<your label>-IRISSpeedTest/terraform.err
```

Either way, you will see the error eventually. Here is a list of errors I encountered:
* "ExpiredToken: The security token included in the request is expired": Your AWS credentials have expired and you need to get a new one. Repeat the step "Getting your AWS Credentials" and just run the ./provision.sh script again.
* "Error import KeyPair: InvalidKeyPair.Duplicate: The keypair 'asamary-IRISSpeedTest' already exists.": There is already a key called "<your label>-IRISSpeedTest" on EC2. Open EC2 on AWS, go to Key Pairs, find it and delete it.

It is normal to see some instances of "SSH operation failed" on the output. The machines are being provisioned by AWS and ICM keeps trying to SSH into them to continue with the setup process. If AWS hasn't finished provisioning the machines, we will get an SSH error. That is normal and ICM will just retry.

## Deploy IRIS

Run the **deployiris.sh** script. It deploys InterSystems IRIS for you.

You will notice that ICM will write on the screen the URL for the management portal. Save that. You will be able to open the management portal using the user **SuperUser** and the password **sys**. 

Notice that there is a namespace called SPEEDTEST. This is where the speed test table will be created. You will be able to look at its contents during and after the speed test is run.

### ICM Deploy IRIS Troubleshooting

You may get the following error when trying to deploy IRIS:

```bash
Thread exited with value 137
````

If you get this error, it is because there was a problem with the initial setup of "IRIS Durable %SYS" and this problem is hard to fix. Trying to redeploy IRIS will not fix it. I fixed it by simply unprovisioning the infrastructure, cleaning up and provisioning it again.

## Deploy the Speed Test

Run the **deployspeedtest.sh** script. It will present you a menu asking which speed test you want to deploy. The choices right now are only "iris" and "hana". Choose the database you want to test. It will deploy the speed test for that.

If you choose IRIS, it will automatically configure the speed test to the IRIS end point you just deployed. Take note of the URL where the IRIS Speed Test UI is deployed and open it. 

## Run the Speed Test

You will see the **Run Test** button. Click on it to start the speed test.

## Unprovision

Run the unprovision.sh script. It will destroy all the machines, storage and network configurations provisioned.

If you plan on running ./provision.sh again with the same configuration, run a ./clean.sh first. It will remove the old State directory and make sure you start "clean" again.
