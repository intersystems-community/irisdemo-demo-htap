# Running the HTAP Speed Test on AWS using ICM

We are using [InterSystems Cloud Manager (ICM)](https://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=GICM_oview) to help us to provision the infrastructure for these Ingestion tests on AWS. 

ICM is built on top of Terraform and allows you to declare your infrastructure as code (a very simple JASON file) and to provision it. ICM also allows you to deploy InterSystems IRIS in this infrastructure in a variety of configurations:
* A simple IRIS database server
* An IRIS database server with a replica (mirror) on a second availability zone (data center)
* A full blown IRIS database server with shards and compute nodes
* etc.

Finally, you can use ICM to deploy your own application as Docker images! This HTAP Speed Test is packaged like this. See the architecture of the Speed Test [here](https://github.com/intersystems-community/irisdemo-demo-htap/blob/master/README.md) for more information. ICM will deploy all of this automatically for you on AWS.

**This folder has scripts that are written to make using ICM with AWS very easy!** 

Here is how it will work:

![Deployment Diagram on AWS](/ICM/aws_speedtest_deployment.png?raw=true)

On step 1, you use the provided scripts to:
* Provision the infrastructure on AWS
* Deploy InterSystems IRIS on AWS
* Deploy The Speed Test for IRIS on AWS
* Deploy The Speed Test for the other database you are comparing IRIS with on AWS

Then, on step 2, you need to manually deploy the other database you are comparing IRIS with manually. Don't worry! We will guide you all the way!

# Pre-Requisites

To run the HTAP Speed Test with IRIS on AWS, you will need:
* Git installed on your machine so you can clone this repository on your local PC
* Docker installed on your machine so you can run ICM
* An **IRIS 2020 License for Ubuntu**. Careful: This must not be a docker based license. We are using ICM to deploy a containerless installation of IRIS on AWS.
* IRIS 2020 install kit for Ubuntu
* ICM 2020 docker image

If you are a supported InterSystems customer, you can download **IRIS for Linux Ubuntu** and an IRIS license from the [Evaluation Service](https://evaluation.intersystems.com).

You will also need to go to the [Worldwide Response Center (WRC)](https://wrc.intersystems.com) and download ICM for IRIS 2020. If you need help, just send an e-mail to support@intersystems.com and we will be glad to help!

If you are not an InterSystems customer, you will still be able to run the HTAP Speed Test on your PC comparing IRIS with some databases such as MySQL and SQL Server. Just follow instructions [here](https://github.com/intersystems-community/irisdemo-demo-htap/blob/master/README.md).


# Preparing the Environment

You must execute the following steps, independently of which database you want to test on AWS.

## 1. Clonning the repo

Clone this repository to your git folder on your PC:

```bash
git clone https://github.com/intersystems-community/irisdemo-demo-htap
```

## 2. Copy the IRIS license key

Put the iris.key file on the folder **./irisdemo-demo-htap/ICM/ICMDurable/license/**. Make sure there is only one license key file there. If you let more than one key file there, you may have problems.

## 3. Preparing ICM to be run and IRIS to be deployed

You downloaded InterSystems IRIS and ICM from the [Evaluation Service](https://evaluation.intersystems.com) and [Worldwide Response Center (WRC)](https://wrc.intersystems.com) as per instructions above and now you must have two tar.gz files like these:

```bash
IRIS-2020.1.0.199.0-lnxubuntux64.tar.gz
icm-2019.4.0.383.0-docker.tar.gz
```

**Please, notice that the IRIS tar.gz is NOT a docker image. It is a normal IRIS install kit for Ubuntu.**

Copy the IRIS install kit to the folder **ICM/ICMDurable/IRISKit/**.

ICM must be loaded into your local docker installation with the following commands:
```bash
docker load --input ./icm-2019.4.0.383.0-docker.tar.gz
Loaded image: intersystems/icm:2019.4.0.383.0
```

## 4. Configure CONF_IRISVERSION

Look inside the file **./irisdemo-demo-htap/ICM/ICMDurable/CONF_IRISVERSION**. You will see the version of IRIS/ICM we are using:

```bash
2020.1.0.199.0
```

Make sure it matches the version of ICM you just loaded. You can change it to match the version of ICM you just downloaded.

## Configuring AWS Credentials

You must add your AWS Credential to file ICM/ICMDurable/aws.credentials. It looks like this:

```
[default]
aws_access_key_id = ABCDEFGHIJKLMNOPQRSTUVWXYZ
aws_secret_access_key = dsfsDFSDFSDSD4534534FDG4FDGD
aws_session_token = A_VERY_LARGE_STRING_ENDED_WITH==
```

# Deploying and Running the Speed Test

Al right! You are ready to go! :)

Proceed with one of the comparisons bellow:
* [InterSystems IRIS x SAP HANA](/ICM/DOC/IRIS_x_SAPHANA.md)
* InterSystems IRIS x AWS Aurora (soon)
* InterSystems IRIS x SQLServer (soon)