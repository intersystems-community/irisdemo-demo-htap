# Running the HTAP Speed Test on Kubernetes

This guide provide instructions on how to run the HTAP Speed Test with InterSystems IRIS on a Kubernetes cluster on AWS (using EKS).

For now, although possible, we have not documented the instructions of how to run the Speed Test on Kubernetes with other databases. 

As when running the Speed Test with ICM, we have created shell scripts that will help the user to create a deployment folder with all 
that is needed to deploy the full Speed Test on EKS.

Here is how it will work:

* **Setup** - Run the setup.sh script and answer a questionnaire about the size of the machines you want, if you want mirroring or not and the number of workers. The setup script will create a folder with everything you need to deploy your cluster.
* **Provision** - Go to the folder that was created by the setup script and run the provision.sh script to get your Kubernetes cluster created for you
* **Deploy** - On the same folder, Deploy InterSystems IRIS and the Speed Test on the Kubernetes cluster
* **Test** - Run the speed test!
* **Unprovision** - Remove the speed test and IRIS from your Kubernetes cluster and, if running on EKS, destroy the cluster.

Start by cloning this repository to your git folder on your PC:

```bash
git clone https://github.com/intersystems-community/irisdemo-demo-htap
```

# 1 Configuring and Provisioning the Speed Test on your Local Kubernetes 

To run the HTAP Speed Test on your machine you will need a local installation of Kubernetes and kubectl. Docker Desktop provides both. You can just enable Kubernetes on your existing docker desktop installation.

Enabling Kubernetes on docker desktop takes several minutes to complete but will also automatically install KubeCTL for you.

## 1.1 Configuring the Test (local)

To begin, go into to **./irisdemo-demo-htap/Kubernetes/**. From there, you will see a script called setup.sh. Run it, and go through the steps in the script. **MAKE SURE TO SAY YES TO RUNNING THE TEST LOCALLY**. 


```bash
./setup.sh

Please enter with the label for your machines (ex: asamaryCluster1): <MACHINE LABEL>

Are you going to deploy the demo locally (answer yes or something else if not)?: yes

How many Ingestion Workers?: 1

How many Query Workers?: 1

You can now change to Deployments/<MACHINE LABEL> and run ./provision.sh to provision the infrastructure on EKS.
```

## 1.2 Deploying the Test (local)

Now you can change into the new directory that the setup script gives you. 

Once there run **./provision.sh** to setup everything into your local Kubernetes Cluster.





# 2 Configuring and Provisioning the Speed Test on AWS EKS

To run the HTAP Speed Test with InterSystems IRIS on AWS, you will need:
* An AWS account
* [EKSCTL](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html) - This is the AWS command line interface (CLI) that will be used by the scripts to programatically deploy the Kubernetes cluster on your AWS account.
* [KubeCTL](https://kubernetes.io/docs/tasks/tools/install-kubectl/) - This is used by the scripts to deploy InterSystems IRIS and the Speed Test on your Kubernetes cluster. It is installed by default on your machine when you have Docker Desktop or MiniKube. But you can also follow the instrutions on the link to manually install it.
* [Helm](https://helm.sh/docs/intro/install/) - This is required because we use IKO (InterSystems Kubernetes Operator) and to install IKO on your cluster, you need Helm (Kubernetes' package manager). 
* You will also need an IRIS license. If you are a supporter InterSystems customer, you can get a license to try IRIS on Kubernetes from https://evaluation.intersystems.com. 
* [InterSystems Kubernetes Operator](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=AIKO) - We use this to deploy IRIS on the Kubernetes Cluster. 
* An **InterSystems IRIS 2020 License**. If you are deploying the speed test with sharding, you must get an **InterSystems IRIS Advanced Server License** which is the only license that allows sharding. If you are a supported InterSystems customer, you can download an InterSystems IRIS license from the [Evaluation Service](https://evaluation.intersystems.com). If you are not an InterSystems customer, you will still be able to run the HTAP Speed Test on your local Kubernetes cluster using IRIS Community.

## 2.1 Configure the Environment

Follow the instructions on [this page](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html) to get the AWS CLI, EksCtl and KubeCtl installed on your local PC.

## 2.2 Install Helm

Follow instructions on [this page](https://helm.sh/docs/intro/install/) to get Helm installed on your local PC.

## 2.3 Copy the InterSystems IRIS license key

Put the iris.key file on the folder **./irisdemo-demo-htap/Kubernetes/license/**. Make sure that the license is for **IRIS on containers**.

## 2.4 Get InterSystems Kuberbetes Operator

The Speed Test has been tested with **IKO version 2.1.0.7.0**. 

Helm must be used to install IKO on the Kubernetes cluster. Typically, all it takes is a command and Helm does everything for us. Unfortunately, IKO is yet not in the official Helm repository which makes our lives a little bit harder. **We need to manually get IKO from InterSystems** and use Helm to push it into the Kubernetes cluster. In the near future, IKO will be on Helm is this step will not be necessary anymore. 

If you are a supported customer, you can go to [WRC](https://wrc.intersystems.com) and navigate to Software Distributions > InterSystems Components and download IKO. Make sure you dowload a version that is equal or superior to 2.1.0.7.0.

Extract tar into the folder the folder inside and place it in **./irisdemo-demo-htap/Kubernetes/IKO**.

## 2.5 Configuring AWS Credentials

If you just installed AWS CLI, enter with the following command to configure your AWS credentials:

```
aws configure
```

Make sure your credentials are up to date on your machine. If you have run **aws configure** once, you can also go to your default AWS credential file (**~/.aws/credentials**) and make sure it's the latest one. Here is an example of the contents of this file:

```
[default]
aws_access_key_id = ABCDEFGHIJKLMNOPQRSTUVWXYZ
aws_secret_access_key = dsfsDFSDFSDSD4534534FDG4FDGD
aws_session_token = A_VERY_LARGE_STRING_ENDED_WITH==
```

## 2.6 Configuring the Test (EKS)

Now that you're setup, go into to **./irisdemo-demo-htap/Kubernetes/**. From there, you will see a script called **setup.sh**. Run it, and go through the steps in the script:

```
Please enter with the label for your Kubernetes cluster (ex: asamaryCluster1): johnSpeedTest


Are you going to deploy the demo locally (answer yes or something else if not)?: no


Are you using IRIS Community (answer yes or something else if not)?: no


Enter your Docker Username: <Your Docker Username>


Enter your Docker Password: <Your Docker Password>


Do you want IRIS with Mirroring (answer yes or something else if not)?: yes


Do you want IRIS with Sharding (answer yes or something else if not)?: no


How many Ingestion Workers?: 1


How many Query Workers?: 1


Please enter with the AWS instance type:
	 1 - r5.2xlarge io1 100 GB 2500 IOPS

	 2 - r5.2xlarge io1 500 GB 2500 IOPS

Choice: 2
 r5.2xlarge io1 500 GB 2500 IOPS...


You can now change to Deployments/johnSpeedTest and run ./provision.sh to provision the infrastructure on Kubernetes.
```

## 2.7 Deploying the Test (EKS)

Now you can change into the new directory that the setup script gives you. Once there run **./provision.sh** to setup everything into your Kubernetes Cluster. **THE CLUSTER PROVISIONING STEP CAN TAKE A VERY LONG TIME (30-40 minutes)**

Once it's finished, enter the following in your command line to create a tunnel to the Kubernetes cluster so you can open the Speed Test UI:
```bash
kubectl port-forward svc/ui 4200:4200
```

Now you can open the Speed Test UI at http://localhost:4200.

**NOTE**
We are forwarding the service's port to localhost for numerous reasons:
* Ingress costs money
* It spins up a LoadBalancer
* Setting up the project becomes slower
* Upon doing many tests, we found that it causes issues on cleanup, having some resources not be deleted.


# 3 Running the SpeedTest

Once provisioning is finished and you have your tunnel to the Speed Test UI created, open **http://localhost:4200** to access the SpeedTest UI. 

Just click on the **Run Test** button to run the Speed Test Demo! It will run for a maximum time of 300 seconds or until you manually stop it. 

If you want to change the maximum time to run the test, click  the **Settings** button at the top right of the UI. Change the maximum time to run the speed test to whatever you want. 

After clicking on **Run Test**, it should immediately change to **Starting...**. It may stay on this status for a long time since we are pre-expanding the database to its full capacity before starting the test (something that we would normally do on any production system). InterSystems IRIS is a hybrid database (In Memory performance with all the benefits of traditional databases). So InterSystems IRIS still needs to have its disk database properly expanded. Just wait for it. 

**Warning**: InterSystems IRIS Database expansion can take some time. Fortunately, when running on your PC, we will pre-expand the database only to up to 9Gb since InterSystems IRIS Community has a limit on the database size.

When the test finishes running, a green button will appear, allowing you to download the test results statistics as a CSV file.


## 4 Opening InterSystems IRIS Management Portal

If you want to access the System Management Portal, you can port-forward the appropriate ports in the iris pod using KubeCTL. In order to do this, enter the following in your command line:

```
kubectl port-forward svc/htapirisdb 52773:52773
```

You will now be able to open the management portal at the URL http://localhost:52773/csp/sys/UtilHome.csp.

## 5 Removing the Speed Test from your local Kubernetes cluster

Once you're done, run **./unprovision.sh** to remove everything from your local Kubernetes cluster. If running on EKS, **./unprovision.sh** will also destroy the cluster. If **./unprovision.sh** fails, run it again.
