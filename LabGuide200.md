# Lab 200: Disaster Recovery - Part 2: Automation & Traffic Steering

<!-- Comment out table of contents
## Table of Contents
[Introduction](#introduction)
-->

![](./screenshots/200screenshots/intro.png " ")

## Introduction

This lab walks your through how to automate your block and boot volumes backups to a new region. Should disaster strike your home region, it is critical to have the backups elsewhere. Then you will configure the Traffic Management policy where if your servers in your home region are down, your DNS entry will re-route visitors to your site to your standby region.

[Lab 200 Walkthrough Video]()

### Objectives
- Configure DNS failover to standby region in traffic management
- Run attached Python scripts to take backups and move them from primary to standby region

### Required Artifacts
-   Attached Python scripts
    - block-volume-migration.py
    - boot-volume-migration.py
-   Configure OCI SDK
-   Relevant IAM permissions in your tenancy to manage [DNS](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/dnspolicyreference.htm) & [block volumes](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Reference/corepolicyreference.htm#Details_for_the_Core_Services)

### Extra Resources

- [DNS traffic management](https://docs.cloud.oracle.com/en-us/iaas/Content/EdgeServices/overview.htm)
- [Installing the OCI Python SDK](https://oracle-cloud-infrastructure-python-sdk.readthedocs.io/en/latest/installation.html)
- [Creating Volume Backups](https://docs.cloud.oracle.com/en-us/iaas/Content/Block/Concepts/blockvolumebackups.htm)
- [Copying Volume Backups](https://docs.cloud.oracle.com/en-us/iaas/Content/Block/Tasks/copyingvolumebackupcrossregion.htm)
- [Restoring Volume backups](https://docs.cloud.oracle.com/en-us/iaas/Content/Block/Tasks/restoringavolumefromabackup.htm)

## Part 1. DNS traffic steering

![](./screenshots/200screenshots/2.png " ")

From the OCI console, under networking go to the traffic steering policies.

![](./screenshots/200screenshots/3.png " ")

Create a failover traffic steering policy.

![](./screenshots/200screenshots/4.png " ")

This policy will point your DNS to your standby region's load balancer if your primary region's load balancer fails the health check. 

![](./screenshots/200screenshots/5.png " ")

You can get your load balancer IPs from Netowrking -> Load balancers. Make sure you are in the correct regions. 

![](./screenshots/200screenshots/6.png " ")

You can see, we switch regions on the upper right to get the IP of the LB in the standby region, Frankfurt.

![](./screenshots/200screenshots/7.png " ")

![](./screenshots/200screenshots/8.png " ")
Input the information like above. 
![](./screenshots/200screenshots/9.png " ")
Make sure to attach the health check to your primary region's load balancer, this is what determines if traffic should be re-directed to your standby region. 

![](./screenshots/200screenshots/1.png " ")
![](100screenshots/Failover-Policy.png)

This is a summary of your traffic steering policy.


## Part 2. Running the Python scripts

### **STEP 0**: What do the scripts do

1.   Boot Volume script (boot-volume-migration.py) takes all volume from one region for a given compartment and restores this volume across any given region thru volume backups

```
usage: boot-volume-migration.py [-h] 
            --compartment-id COMPARTMENT_ID

            --destination-region DESTINATION_REGION

            --availability-domain AVAILABILITY_DOMAIN
```

2. Block Volume script (block-volume-migration.py) takes all volume from one region for a given compartment and restores this volume across any given region thru volume backups
```
usage: block-volume-migration.py [-h] 
             --compartment-id COMPARTMENT_ID

             --destination-region DESTINATION_REGION

             --availability-domain AVAILABILITY_DOMAIN
```
Steps in the automation scripts:
1. create_volume_backups in source region
2. copy_volume_backups across destination region
3. restore_volume in destination region

### **STEP 1**: Configure the scripts for your tenancy

-   Once at the [homepage](https://demo.oracle.com/apex/f?p=DEMOWEB:HOME::::::), navigate to the "Demos" section. 

### **STEP 2**: Run the scripts

Below is the command to run each script.
```
python block-volume-migration.py --compartment-id ocid1.compartment.oc1..123 --destination-region eu-frankfurt-1 --availability-domain AD-2
```

```
python boot-volume-migration.py --compartment-id ocid1.compartment.oc1..aaaaanq --destination-region eu-frankfurt-1 --availability-domain AD-2
```

Below you can see the volume backups now created in your source region, our's is London.

![](./screenshots/200screenshots/source.png " ")

And in your destination region, you should be able to see the backups there as well from your specified source region.

![](./screenshots/200screenshots/destination.png " ")

-   Click the **Register a Demo**.




## Summary

-   In this lab, you used the OCI Python SDK to automate your block volume backups to another region, and then restore them. You configured your DNS to route to your standby-DR region in the event of a disaster in your primary region. In the next lab, we will be simulating a disaster.

-   **You are ready to move on to the next lab!**

[Back to top](#introduction)

