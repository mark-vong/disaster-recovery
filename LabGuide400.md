# Lab 400: Using Rsync for application file sync
<!-- Comment out table of contents
## Table of Contents
[Introduction](#introduction)
-->

## Introduction

Welcome to an introduction of rsync. Rsync is a file copying tool that exists on most linux environments. It is capable of copying files locally and to/from another host over a remote shell. Its differentiating feat is its delta-transfer algorithm that focuses on syncing the changes observed in files. This optimizes the sync by reducing the amount of data sent over the network. Rsync is used extensively in backups, disaster recovery, and mirroring scenarios. 

For this lab specifically, we will be working in the terminal exclusively. As a result, we've included the commands to run as we walk you through the lab steps. 

In the first part of this lab, we will sync files locally on our machines to get an introductory grasp of rsync. 

In the second and final part of the lab, we will simulate how an administrator would sync files between a local machine and a remote server.

*This lab will leverage the existing infrastructure that was created previously from the terraform script.* 

### Objectives
- Understand the syntax of rsync.
- Sync files locally.
- Sync files between a local host and a remote server.

### Extra Resources
-   To learn more about rsync, please refer to the following Linux documentation: [rsync](https://linux.die.net/man/1/rsync)
-   To learn more about specific rsync use cases, please refer to the following tutorial [rsync usage](https://www.digitalocean.com/community/tutorials/how-to-use-rsync-to-sync-local-and-remote-directories-on-a-vps).

## Part 1. Syncing files between two folders on the same machine.

### Step 1. Create two folders. Name one "primary_sync" and the other "standby_sync".

```
$ mkdir primary_sync standby_sync

$ ls 
```

### Step 2. Create a file in "primary_sync" and name it "primary.txt".

```
$ touch primary_sync/primary.txt

$ ls primary_sync 
```

### Step 3. Verify that only "primary_sync" has a file in it and "standby_sync" is empty.

```
$ ls primary_sync/ standby_sync/
```

### Before we use rsync to sync the file between the folders, a little about the option flags we'll be using:
#### -a represents "archive". It allows us to sync all files in the source directory recursively while preserving any symbolic links, special and device files, modification times, group, owner, and permission.
#### -v represents "verbose". This flag lets us know what's happening when the command is run.
#### -P represents the combination of the "progress" and "partial" flags which allow us to see the transfer progress bar as well as the resumption of interrupted transfers.
#### -n represented "dry-run". This flag shows what content would have been transferred, useful to test out connectivity to the target host as well as target folder access. 

### Step 4. Great, now let's execute our first sync between the two folders. Let's include the "-n" flag first to make sure everything is in place before we actually sync the file.

```
$ rsync -avP primary_sync/ standby_sync -n

$ ls primary_sync/ standby_sync/
```

### Step 5. Removing the "-n" flag will sync the file over to the "standby_sync" folder.
```
$ rsync -avP primary_sync/ standby_sync 
 
$ ls primary_sync/ standby_sync/
```
### Nice work! You've successfully used rsync to sync a file between two local folders.



Navigate from the upper left hamburger menu to networking -> Load balancers. Find the Load Balancer in your primary region.

![](./screenshots/300screenshots/2.png)

Go to your backend set. 

![](./screenshots/300screenshots/3.png)

Check mark your backends. Then press actions.

![](./screenshots/300screenshots/4.png)

Set the drain state to True. This will stop all current connections and simulate the disaster. 

![](./screenshots/300screenshots/5.png)

Your health check on your primary region is now failing, and traffic hitting your DNS should now be routed to your standby region. 
![](./screenshots/300screenshots/300a.png)

If you installed the HTML to your standby server, you should now see this. You can see our DNS entry - 'oci.life' with the subdomain 'alexmcdonald'.
![](./screenshots/300screenshots/300c.png)

If you navigate to health/check traffic steering - you can see the health for the Primary region load balancer is now critical. If you visit the IP address of this load balancer, you will get 502 bad gateway. 

Now, enter your DNS url in your web browswer, you should see the HTML indicating you are now seeing traffic steered to your standby region. 

## Part 2. Scaling the standby region compute node

### **STEP 1**: Configure SDK

Please follow steps in [lab200](https://github.com/arshyasharifian/DR_DNS/blob/master/LabGuide200.md) to configure the SDK for your python scripts to call resources in your tenancy.

### **STEP 2**: Run Python scripts

This [link](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs) will help you setup the rest api key that python needs to run scaling script.
This [link](https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/sdkconfig.htm) example of a configuration file.
*The script will not continue unitl the scaling is complete. Check the OCI console work request to see when the instance will be available again.*
![](./screenshots/300screenshots/python-scaling.PNG)

*The instance will be shutdown while the update takes place.*
![](./screenshots/300screenshots/Scaling-Start.PNG)

*You can now log into the instance again*
![](./screenshots/300screenshots/Scaling-Finished.PNG)

## Summary

-   In this lab, you learned how to simulate a disaster event, and redirect traffic to your standby region.

-   **You are ready to move on to the next lab!**

[Back to top](#introduction)

