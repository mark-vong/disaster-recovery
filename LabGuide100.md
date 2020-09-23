# Disaster Recovery Network and Connectivity Setup

## Introduction

This solution provides a Network Architecture deployment to demonstrate a Disaster Recovery scenario across regions.

### Objectives
- Deploy DR network and infrastructure on OCI using Terraform.
- Configure network and infrastructure settings through the Oracle Cloud console.

### Extra Resources
- [Introduction to OCI](https://docs.cloud.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)

**Note:** This is **not** configured for a production environment. **This is just for demo purposes.**

## Quickstart Deployment
### Prerequisites
1.  Create your own private/public key pair on your local system.
2.  Move the key pair to the resource-manager-bin/keys/ folder.
3.  Zip up all of the files from resource-manager-bin folder. The zip file name is not important.
    Just make sure it has the following file structure.
    
        resource-manager-bin/
        ├── assets 
        │   ├── images
        │   │   └── oracle.png
        │   ├── scripts
        │   │   ├── block-volume-migration.py
        │   │   ├── boot-volume-migration.py
        │   │   ├── cloud_init_checker.sh
        │   │   └── README.md
        │   └── templates
        │       ├── bootstrap_dst.tpl
        │       └── bootstrap_src.tpl
        ├── data_sources.tf
        ├── dr_schema.yaml
        ├── keys
        │   ├── id_rsa
        │   ├── id_rsa.pub
        ├── main.tf
        ├── modules
        │   ├── bastion_instance
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── variables.tf
        │   ├── iam
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── variables.tf
        │   ├── lb
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── variables.tf
        │   ├── network
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── variables.tf
        │   ├── server
        │   │   ├── main.tf
        │   │   ├── outputs.tf
        │   │   └── variables.tf
        ├── outputs.tf
        ├── providers.tf
        ├── README.md
        ├── terraform.tfvars
        └── variables.tf

### Inputs
*The following inputs are required for terraform modules:*

```
Argument
Description

region
Primary region in which to operate, example: us-ashburn-1, us-phoenix-1, ap-seoul-1, ap-tokyo-1, ca-toronto-1 

dr_region
DR region in which to operate, example: us-ashburn-1, us-phoenix-1, ap-seoul-1, ap-tokyo-1, ca-toronto-1

dr_vcn_cidr_block
CIDR block of the VCN (Virtual Cloud Network) to be created in DR region. make sure the VCN CIDR blocks of primary and DR regions do not overlap

vcn_cidr_block
CIDR block of the VCN (Virtual Cloud Network) to be created in primary region. make sure the VCN CIDR blocks of primary and DR regions do not overlap

vcn_dns_label
DNS Label of the VCN (Virtual Cloud Network) to be created.

bastion_server_shape
This is the compute shape for bastion server. For more information on available shapes, see VM Shapes

app_server_shape
This is the compute shape for application servers deployed in primary region for hosting application. For more information on available shapes, see VM Shapes

lb_shape
A template that determines the total pre-provisioned bandwidth (ingress plus egress). To get a list of available shapes, use the ListShapes operation. Example: 100Mbps
```

## Resource Manager

The following section will show you how to configure resource manager to make the deployment easier. Anything that is 
shaded out on the page. You will not be able to configure.

### Configuration 

1.  Navigate to the resource manager tab in oci. Next upload the zip file to the stack.
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager.PNG)
    
2.  Input the configuration for the instances.
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Compute.PNG)

3.  Input the configuration for the vcn
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Network.PNG)
    
4.  Input the configuration for the load balancer
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-LB.PNG)
    
5.  Input the configuration for the keys. Since the keys are in the zip file and in the keys folder, make sure to put "./keys/" in front of the key names.
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Keys-N.PNG)
    
    ### Review process
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Review-N.PNG)
    
### Plan

1.  Select plan from the dropdown menu.
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Plan-1.PNG)
    
2.  Make sure everything looks okay and then proceed
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Plan-2.PNG)

3.  Wait until the icon turns green.
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Plan-3.PNG)
    
### Apply
    
    
1.  Select apply from the dropdown menu. 
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Apply-1.PNG)
    
2.  Wait until the icon turns green.
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Apply-2.PNG)


### Destroy
 If you want to delete the infrastructure.
    First navigate to OCI Console and terminate the DR database and once the termination is successful then resource manager can be used to destroy the environment.
1.  Select destroy from the dropdown menu. 
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Destroy.PNG)

2.  Wait until the icon turns green.
    ![](./screenshots/100screenshots/resource-manager-files/ResourceManager-Destroy-2.PNG)


### Example of the results terraform will produce.
 *Example: Instances in the Primary Region*

 ![](./screenshots/100screenshots/App-Server(Primary)-N.PNG)

 *Example: Instances in the DR Region*

 ![](./screenshots/100screenshots/App-Server(Secondary)-N.png)
 
## Configuring the DNS for failover.

### Create a Health Check
1.  Navigate to the upper left hamburger menu, expand **Networking** and click on **Health Checks**.
    ![](./screenshots/100screenshots/health-check/health-check-console.png)

2.  Click on **Create Health Check** and provide the appropriate information. _Make sure to attach the **Primary** load balancer as a target_. You may choose whichever [vantage points](https://docs.cloud.oracle.com/en-us/iaas/Content/HealthChecks/Concepts/healthchecks.htm) you would like. The **Request Type** and **Protocol** should both be **HTTP**. The **Method** should be **HEAD**. Leave everything else as their default values.

    ![](./screenshots/100screenshots/health-check/health-check-name.png)

    ![](./screenshots/100screenshots/health-check/health-check-port.png)

    ![](./screenshots/100screenshots/health-check/health-check-tag.png)

### Create a new DNS zone
1. Navigate to the upper left hamburger menu, expand **Networking** and click on **DNS Zone Management**.
    ![](./screenshots/100screenshots/dns-zone/dns-zone-console.png)

2. Click on **Create Zone**.
    ![](./screenshots/100screenshots/dns-zone/dns-zone-create.png)

3. Provide a **Zone Name**. This value has to be the same as an internet accessible domain hosted on either godaddy or freenom. The **Zone Type** should be **Primary**. Once created, please connect your DNS with the provided nameservers provided through the service console.
    ![](./screenshots/100screenshots/dns-zone/dns-zone-info.png)


### Create a Traffic Management Steering Policy
1.  From the OCI console, under networking go to the traffic steering policies.
    ![](./screenshots/100screenshots/traffic-management/2.png " ")


2.  Create a failover traffic steering policy.
    ![](./screenshots/100screenshots/traffic-management/3.png " ")


3.  This policy will point your DNS to your DR region's load balancer if your primary region's load balancer fails the health check. 
    ![](./screenshots/100screenshots/traffic-management/policy-name.png " ")


4.  You can get your load balancer IPs from Networking -> Load balancers. Make sure you are in the correct regions. 
    ![](./screenshots/100screenshots/traffic-management/primary-lb.png " ")


5.  You can see, we switch regions on the upper right to get the IP of the LB in the DR region, Phoenix.
    ![](./screenshots/100screenshots/traffic-management/dr-lb.png " ")


6.  Provide your answer pools for both of your regions.
    ![](./screenshots/100screenshots/traffic-management/answer-pool-1.png " ")

    ![](./screenshots/100screenshots/traffic-management/answer-pool-2.png " ")


7.  Make sure to attach the previously created health check of your primary load balancer, this is what determines if traffic should be re-directed to your DR region.  
    ![](./screenshots/100screenshots/traffic-management/pool-priority.png " ")

    ![](./screenshots/100screenshots/traffic-management/attach-health-check.png " ")


8.  Provide a subdomain name and attach the previously created DNS zone as an attached domain. 
    ![](./screenshots/100screenshots/traffic-management/attach-domain.png " ")


9.  This is a summary of your traffic steering policy.

    ![](./screenshots/100screenshots/traffic-management/summary-N.png " ")

    ![](./screenshots/100screenshots/traffic-management/overview.png " ")

    ![](./screenshots/100screenshots/traffic-management/domains.png " ")


<!-- ### Attach a subdomain to the DNS zone
1.![](./screenshots/100screenshots/DNS-Zone-Subdomain-Step1.png)

2.![](./screenshots/100screenshots/DNS-Zone-Subdomain-Step2.png)

3.Publish to finish attaching.

![](./screenshots/100screenshots/Failover-Policy-Publish.png) -->

<!-- # Adding Html to the compute instances.

You can place these HTML files in your app-tier compute nodes to demonstrate the DR working by displaying different HTML pages depending on which region you are hitting. You can see this information in the IP address as well, but this is additional visual stimulation.

## Primary Instance
*Follow the instructions in the [html file](HTML-Instructions.txt)*

## Secondary Instance
*Follow the instructions in the [html file](HTML-Instructions.txt)*


## Troubleshooting -->


### End
