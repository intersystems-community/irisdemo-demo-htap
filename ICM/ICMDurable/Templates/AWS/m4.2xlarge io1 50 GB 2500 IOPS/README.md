AWS m4.2xlarge is defined [here](https://aws.amazon.com/ec2/instance-types/). It has:
- 8 cores
- 32Gb of RAM

We can attach EBS volumes to this machine and it has IOPS limitations as described [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-optimized.html). In the case of m4.2xlarge, the limitations are:
- Maximum bandwidth (Mbps): 1000 Mbps
- Maximum throughput (MB/s, 128 KiB I/O): 125 Mb/s
- Maximum IOPS (16 KiB I/O): 8000 IOPS

So, we are limited in three different ways. Max bandwidth coming into the instance (1000 Mbps) and a max throughput of 125 Mb/or 8000 IOPS (whichever comes first).

We must also consider the [types of EBS disks](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-volume-types.html) we want to use. We are considering only two types:
- General Purpose SSD (gp2) - "General purpose SSD volume that balances price and performance for a wide variety of workloads"
  - Volume Size: 1 GiB - 16 TiB
  - Max IOPS per Volume: 16,000 (16 KiB I/O)
  - Max Throughput per Volume: 250 MiB/s *
  - Max IOPS per Instance: 80,000
  - Max Throughput per Instance: 2,375 MB/s
- Provisioned IOPS (io1) - "Highest-performance SSD volume for mission-critical low-latency or high-throughput workloads"
  - Volume Size: 4 GiB - 16 TiB
  - Max IOPS per Volume: 64,000 (16 KiB I/O) 
  - Max Throughput per Volume: 1,000 MiB/s
  - Max IOPS per Instance: 80,000
  - Max Throughput per Instance: 2,375 MB/s


Depending on the type of disk we choose, we may have yet another limitation. AWS throttles IOPS of gp2 EBS devices limiting it to a rate of 3 IOPS / 1GB provisioned.

For typical transactional applications, we want the WIJ and Journal volumes to be fast. So gp2 are good for our Data Volumes because they can be larger and don't rely too much on speed while io1 are perfect for our WIJ and Journal volumes! 

But ingestion is different.

Configuring the system for Ingestion is like traffic engineering. If you make a road wider, you are just moving
the traffic jam ahead, to the next road. Here are our three roads:
- Global Buffers - 32Gb of RAM for m4.2xlarge
- Journal1 / WIJ - io1 with no IOPS throttling limited at 8000 IOPS on m4.2xlarge
- DataVolume - gp2 with 3 IOPS / 1Gb throttling, also capped by 8000 IOPS on m4.2xlarge

We are trying to send as many INSERTs per seconnd as possible, from possibly many workers. So, memory will fill up real quick. Memory is fast and all those INSERTs will quickly reach the next road (journaling and WIJ) and now will be limited to 8000 IOPS. There is nothing we can do, here is our first traffic jam. The workers will be slowed down now because we can only do 8000 IOPS despite the fact that memory is very fast. 

Although out INSERTS are persisted and safe on the WIJ, we still need to move them to the IRIS.DAT. The IRIS.DAT is on the Data Volume and there is a ferry called "Write Daemon" that can take a group of INSERTs and take them safely to the data volume on the other side. But the dock at the other side takes a lot of time to unload the ferry and we are now limited by its IOPS that is throttled at 3 IOPS/1Gb and capped at 8000 IOPS in the case of m4-2xlarge.

That means that if we want to use all the available maximum of 8000 IOPS of our m4.2xlarge, Data Volumes (gp2 volumes) should be of ~2666 Gb. (8000 / 3 = 2666.666...). And that would not be as fast as our WIJ/Journal writing because writing on the data volumes are random (we need to find the right place inside IRIS.DAT where to write the disk block).

So we could configure a template [defaults.json](./defaults.json) file like this:
- WIJVolumeType: io1
- WIJVolumeSize: 200
  - I had to configure this to 200 because I got the following error when trying to provision this with 100: "Iops to volume size ratio of 80.000000 is too high; maximum is 50". So 8000/50 = 160. I configured it to 200.
- WIJVolumeType: io1
- WIJVolumeIOPS": 8000
- WIJVolumeSize: 200GB
- Journal1VolumeType: io1,
- Journal1VolumeSize: 1024
- Journal1VolumeIOPS: 8000
- Journal2VolumeType: io1
- Journal2VolumeSize: 512
- Journal2VolumeIOPS: 8000
- DataVolumeType: gp2
- DataVolumeSize: 2666
- DataVolumeIOPS: Not supported on AWS for gp2 volume types. IOPS will be 3 * 2666 = 7998

But 8000 IOPS would be way too expensive and we would run out of CPU and disk space very quickly. 

This profile has been created for comparing IRIS against SAP HANA Express on m4-2xlarge. So, now that we know a little bit about our own limits on this server, let's look at how much disk and IOPS SAP HANA Express 32Gb is being configured with: 
- EBS Volume Type: io1
- EBS Volume Size: 50Gb
- EBS Volume IOPS: 2500

So, let's give the same to IRIS! Here is our final configuration:
- WIJVolumeType: io1
- WIJVolumeIOPS": 2500
- WIJVolumeSize: 50GB
- Journal1VolumeType: io1,
- Journal1VolumeSize: 200GB
- Journal1VolumeIOPS: 2500
- Journal2VolumeType: io1
- Journal2VolumeSize: 100GB
- Journal2VolumeIOPS: 2500
- DataVolumeType: io1
- DataVolumeSize: 50
- DataVolumeIOPS: 2500

Please notice that we have configured our Data Volume with an EBS volume type of io1 as well. 

Silly Question: Why does SAP HANA needs a fast disk if it is an in-memory database? :))

Things we can do to improve performance even further:
- Use XEP 
- User an ICM containerless deployment
- Disable encryption on the Weave Network
- Verify impact of asynch WIJ 
- Work with Mark Bolinsky. :)