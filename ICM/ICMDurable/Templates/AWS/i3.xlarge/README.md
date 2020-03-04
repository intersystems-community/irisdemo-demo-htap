AWS i3.xlarge is defined [here](https://aws.amazon.com/ec2/instance-types/). It has:
- 4 cores
- 30Gb of RAM
- 1 x 950Gb NVMe SSD
- Up to 10 Gbps (1.16 GB/s which won't limit us when talking to the EBS volumes we need)

We have added this machine because SAP HANA 32GB supports it and it has an internal NVMe SSD disk which is ultra fast.

We will continue using EBS for WIJ, data volumes and the database. We wanted to leave the journal files on the local NMVe disk because they are ultra fast. But ICM won't let us do it until ICM 2020.2. So, for now, we will let journal files on EBS as well.

Here is the instructions we got from our team in InterSytems to get ICM configured to use the NVMe storage but it didn't work and we need to wait for 2020.2:

*Set Journal1DeviceName to "null" and Journal2DeviceName to "null". We also need to give them a minimun size of, say 10Gb and minimun IOPS of say 500 IOPS. This is a workaround because ICM 2020.1 will always create these EBS volumes. But because we have set their "devie name" to "null", the IRIS instance will leave the journal files on the local disk instead. 

On ICM 2020.2, this will change. It will sufice to set Journal1DeviceName="local" and these volumes will not even be created so no need to specify minimal sizes and IOPS for them:*

```json
    "Journal1DeviceName": "null",
    "Journal1VolumeType": "io1",
    "Journal1VolumeSize": "10",
    "Journal1VolumeIOPS": "500",

    "Journal2DeviceName": "null",
    "Journal2VolumeType": "io1",
    "Journal2VolumeSize": "10",
    "Journal2VolumeIOPS": "500",
```

The data and WIJ volumes are both using EBS with a maximum IOPS of 2500 because that is the IOPS of SAP HANA's volumes.