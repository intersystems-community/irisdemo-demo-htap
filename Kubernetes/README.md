# Running the HTAP Speed Test on Kubernetes

We are using Kubernetes to deploy Intersystems IRIS and to provision the infrastructure for these Ingestions tests. In order to run IRIS on Kubernetes, you are going to need KubeCTL, the Kubernetes Command-Line tool!


**This folder has scripts that are written to make running the HTAP demo on Kubernetes easy** 

Here is how it will work:

On step 1, you use the provided scripts to:
* Setup the speedtest according to the selections you make.
* Provision the Kubernetes cluster, with the appropriate machines.
* Deploy InterSystems IRIS on the Kubernetes cluster
* Deploy The Speed Test for InterSystems IRIS on this cluster.

# Pre-Requisites

To run the HTAP Speed Test with InterSystems IRIS on AWS, you will need:
* An AWS account
* Git installed on your machine so you can clone this repository on your local PC
* Docker Desktop or KubeCTL installed on your machine (if you're running the test locally)
* An **InterSystems IRIS 2020 Advanced Server License WITH sharding**. 
* IRIS Kubernetes Operator if using non-Community IRIS
* Helm if using IKO

If you are a supported InterSystems customer, you can download an InterSystems IRIS license from the [Evaluation Service](https://evaluation.intersystems.com).


If you are not an InterSystems customer, you will still be able to run the HTAP Speed Test on your PC or on AWS, using the Community version of IRIS.


# Preparing the Environment

## 1. Cloning the repo

Clone this repository to your git folder on your PC:

```bash
git clone https://github.com/intersystems-community/irisdemo-demo-htap
```

## 2.1 Running the Test Locally

If you don't have it installed, download and install **Docker Desktop**, and enable Kubernetes. It will take some minutes to turn on completely, but will also automatically install KubeCTL for you.

To begin, go into to **./irisdemo-demo-htap/Kubernetes/**. From there, you will see a script called setup.sh. Run it, and go through the steps in the script. **MAKE SURE TO SAY YES TO RUNNING THE TEST LOCALLY**. 


```bash
./setup.sh

Please enter with the label for your machines (ex: asamaryCluster1): <MACHINE LABEL>

Are you going to deploy the demo locally (answer yes or something else if not)?: yes

How many Ingestion Workers?: 1

How many Query Workers?: 1

You can now change to Deployments/<MACHINE LABEL> and run ./provision.sh to provision the infrastructure on EKS.
```

Now you can change into the new directory that the setup script gives you. 

Once there run **./provision** to setup everything into your local Kubernetes Cluster.

Once it's finished, enter the following in your command line to access the UI:
```bash
kubectl port-forward svc/ui 4200:4200
```

Now you can go to **localhost:4200** to access the SpeedTest UI.

**NOTE**
We are forwarding the service's port to localhost for numerous reasons:
* Ingress costs money
* It spins up a LoadBalancer
* Setting up the project becomes slower
* Upon doing many tests, we found that it causes issues on cleanup, having some resources not be deleted.

If you want to access the System Management Portal, you can port-forward the appropriate ports in the iris pod using KubeCTL. In order to do this, enter the following in your command line:

```
kubectl port-forward svc/htapirisdb 52773:52773
```

Once you're done, run **./unprovision** to remove everything from Kubernetes.

## 2.2 Running the Test on EKS

### 2.2.1 Installing Requirements

You will need the following to run the test on Kubernetes in the cloud:
* EKSCTL
* KubeCTL
* Helm (only if you have a license key and want to run the SpeedTest on full IRIS)

If you don't have **Docker Desktop** or **MiniKube** installed, you can just KubeCTL on your machine.


### 2.2.2 Copy the InterSystems IRIS license key

**Only if you are running the test on Full IRIS**

Put the iris.key file on the folder **./irisdemo-demo-htap/Kubernetes/license/**. You will see that there is a file there called **PLACE IRIS LICENSE KEY HERE**. Make sure to:
1. Delete the file "PLACE IRIS LICENSE KEY HERE"
2. There is only one license key file on the folder. If you let more than one key file there, you may have problems.
3. You are using the right iris.key for your scenario. We are deploying a containerd IRIS, so you should use an IRIS key for Ubuntu Linux.

### 2.2.3 Copy IKO

**Only if you are running the test on Full IRIS**

Download IKO [here](https://docs.intersystems.com/irisforhealthlatest/csp/docbook/DocBook.UI.Page.cls?KEY=AIKO). **DOWNLOAD VERSION 2.1.0.2.0** Extract the folder inside and place it in **Kubernetes/IKO**.


### 2.2.4 Configuring AWS Credentials

Make sure your credentials are up to date on your machine. Go to your default AWS credential file and make sure it's the latest one. **~/.aws/credentials**

```
[default]
aws_access_key_id = ABCDEFGHIJKLMNOPQRSTUVWXYZ
aws_secret_access_key = dsfsDFSDFSDSD4534534FDG4FDGD
aws_session_token = A_VERY_LARGE_STRING_ENDED_WITH==
```

### 2.2.5 Runnint the SpeedTest

Now that you're setup, go into to **./irisdemo-demo-htap/Kubernetes/**. From there, you will see a script called setup.sh. Run it, and go through the steps in the script. **If you do not have a license key and will not be running the test on full IRIS, answer yes to running the test on IRIS Community.**

```bash
Please enter with the label for your Kubernetes cluster (ex: asamaryCluster1): <CLUSTER NAME>


Are you going to deploy the demo locally (answer yes or something else if not)?: no


Are you using IRIS Community (answer yes or something else if not)?: no


Enter your Docker Username: 


Enter your Docker Password:


Do you want IRIS with Mirroring (answer yes or something else if not)?: yes


Do you want IRIS with Sharding (answer yes or something else if not)?: yes


How many shards do you want?: 4


How many Ingestion Workers?: 1


How many Query Workers?: 1


Please enter with the AWS instance type:
	 1 - r5.2xlarge io1 100 GB 2500 IOPS

	 2 - r5.2xlarge io1 500 GB 2500 IOPS

Choice: 2
 r5.2xlarge io1 500 GB 2500 IOPS...



You can now change to Deployments/<CLUSTER NAME> and run ./provision.sh to provision the infrastructure on Kubernetes.
```

Now you can change into the new directory that the setup script gives you. 

Once there run **./provision** to setup everything into your Kubernetes Cluster. **THE CLUSTER PROVISIONING STEP CAN TAKE A VERY LONG TIME (30-40 minutes)**

Once it's finished, enter the following in your command line to access the UI:
```bash
kubectl port-forward svc/ui 4200:4200
```

Now you can go to **localhost:4200** to access the SpeedTest UI.

**NOTE**
We are forwarding the service's port to localhost for numerous reasons:
* Ingress costs money
* It spins up a LoadBalancer
* Setting up the project becomes slower
* Upon doing many tests, we found that it causes issues on cleanup, having some resources not be deleted.

If you want to access the System Management Portal, you can port-forward the appropriate ports in the iris-svc using KubeCTL. In order to do this, enter the following in your command line:

```
kubectl port-forward svc/htapirisdb 52773:52773
```

Now, you can go [here](http://localhost:52773/csp/sys/%25CSP.Portal.Home.zen?$NAMESPACE=%25SYS) and use the credentials **SuperUser** and **sys** to access it.

Once you're done, run **./unprovision** to remove everything from Kubernetes.