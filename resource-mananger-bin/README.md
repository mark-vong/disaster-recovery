# Disaster Recovery

Disaster Recovery Network and connectivity setup
=======================================================

This solution provides a Network Architecture deployment to demonstrate Disaster Recovery scenario across 2 regions [ examples are geared towards region Ashburn & Phoenix and can be used for any OCI regions].


## Quickstart Deployment

1. Clone this repository to your local host. The `pilot-light` directory contains the Terraform configurations for a sample topology based on the architecture described earlier.
    ```
    $ git clone https://orahub.oci.oraclecorp.com/oci-ocbd-custom-app/disaster-recovery.git
    $ cd disaster-recovery/pilot-light
    ```

2. Install Terraform. See https://learn.hashicorp.com/terraform/getting-started/install.html.

3. Setup tenancy values for terraform variables by updating **env-vars** file with the required information. The file contains definitions of environment variables for your Oracle Cloud Infrastructure tenancy.
    ```
    $ source env-vars
    ```

4. Create **terraform.tfvars** from *terraform.tfvars.sample* file with the inputs for the architecture that you want to build. A running sample terraform.tfvars file is available below. The contents of sample file can be copied to create a running terraform.tfvars input file. Update db_admin_password with actual password in terraform.tfvars file.


5. Deploy the topology:

-   **Deploy Using Terraform**
    
    ```
    $ terraform init
    $ terraform plan
    $ terraform apply
    ```
    When you’re prompted to confirm the action, enter yes.

    When all components have been created, Terraform displays a completion message. For example: Apply complete! Resources: nn added, 0 changed, 0 destroyed.

6. If you want to delete the infrastructure, run:
    First navigate to OCI Console and terminate the Standby database and once the termination is successfull then run the following command
    ```
    $ terraform destroy
    ```
    When you’re prompted to confirm the action, enter yes.


## **Pilot Light disaster recovery Terraform modules structure**

Terraform modules for Pilot Light disaster recovery has the following structure:
```
.
└── pilot-light
    ├── README.md
    ├── assets
    │   ├── images
    │   │   └── oracle.png
    │   ├── scripts
    │   │   ├── README.md
    │   │   ├── block-volume-migration.py
    │   │   ├── boot-volume-migration.py
    │   │   └── cloud_init_checker.sh
    │   └── templates
    │       ├── bootstrap_dst.tpl
    │       └── bootstrap_src.tpl
    ├── data_sources.tf
    ├── env-vars
    ├── main.tf
    ├── modules
    │   ├── bastion_instance
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── dbaas
    │   │   ├── main.tf
    │   │   └── variables.tf
    │   ├── iam
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── lb
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── network
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── object_storage
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── rsync
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── server
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   └── shared_fss
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars
    └── variables.tf

16 directories, 44 files
```

- [**root**]:
  - [env-vars]: This is an environment file to set terraform environment variables on UNIX systems.
  - [datasources.tf]: This is terraform data source file to fetch data for Oracle Cloud Infrastructure resources.
  - [main.tf]: At root level, main.tf calls different modules to create Oracle Cloud Infrastructure resources. 
  - [outputs.tf]: This is the terraform outputs file.
  - [provider.tf]: This is the terraform provider file that defines the provider (Oracle Cloud Infrastructure) and authentication information.
  - [variables.tf]: This is the terraform variables file to declare variables.
  - [terraform.tfvars]: This is an input file to pass values to declared variables.

- [**modules**]: The modules directory contain all the modules required for creating Oracle Cloud Infrastructure resources.
  - [bastion_instance]: This module provisions bastion host & sets-up cron schedule to execute python scripts to backup/restore boot & block volumes across regions.
  - [compute]: This module is used  to create unix and windows compute instances.
  - [dbaas]: This module is used to create Oracle Cloud Infrastructure database system.
  - [iam]: This module is used to create IAM groups, dynamic groups and policies
  - [lb]: This module is used to create Oracle Cloud Infrastructure load Balancing service.
  - [network]: This module is used to create network resources like VCN (Virtual Cloud Network),subnets, internet gateway, service gateway, dynamic routing gateway and NAT (network Address Translation) gateway.
  - [object_storage]: This module is used to create object storage buckets and replication policy
  - [rsync]: This module provisions a compute server in standby region and sets up cron scheduler to run rsync for synchronizing cross-region file storage systems
  - [server]: This module provisions compute servers in primary region and sets up cron scheduler to take snapshots of file storage systems at regular intervals
  - [shared_fss]: This module provisions File Storage System

- [**assets**]: The modules directory contain all the modules required for creating Oracle Cloud Infrastructure resources.
  - [images]: hosts image/s which are used for application demonstration by copying these on block storage attached to private compute instances
  - [scripts]: Python scripts to back/restore boot & block volumes across regions
  - [templates]: These templates are used to setup file storage systems on computes in primary region as source and standby region as destination
  - [iam]: This module is used to create IAM groups, dynamic groups and policies

## Inputs required in the terraform.tfvars file
The following inputs are required for terraform modules:

| Argument                   | Description                                                                                                                                                                                                                                                                                                                                                       |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| dr_region                         | standby region in which to operate, example: us-ashburn-1, us-phoenix-1, ap-seoul-1, ap-tokyo-1, ca-toronto-1> |
| dr_vcn_cidr_block                   | CIDR block of the VCN (Virtual Cloud Network) to be created in standby region. make sure the VCN CIDR blocks of primary and standby regions do not overlap  |
| vcn_cidr_block              | CIDR block of the VCN (Virtual Cloud Network) to be created in primary region. make sure the VCN CIDR blocks of primary and standby regions do not overlap|
| vcn_dns_label              | DNS Label of the VCN (Virtual Cloud Network) to be created.           |
| bucket_display_name              | Display name of the object storage bucket, this name will be prefixed with region name to keep unique name across regions  |
| bastion_server_shape              |  This is compute shape for bastion server. For more information on available shapes, see [VM Shapes](https://docs.cloud.oracle.com/iaas/Content/Compute/References/computeshapes.htm?TocPath=Services#vmshapes)|
| app_server_shape              |  This is compute shape for application servers deployed in primary region for hosting application. For more information on available shapes, see [VM Shapes](https://docs.cloud.oracle.com/iaas/Content/Compute/References/computeshapes.htm?TocPath=Services#vmshapes)|
| db_display_name              |  The user-provided name of the Database Home|
| db_system_shape              |  The shape of the DB system. The shape determines resources allocated to the DB system.For virtual machine shapes, the number of CPU cores and memory and for bare metal and Exadata shapes, the number of CPU cores, memory, and storage. To get a list of shapes, use the [ListDbSystemShapes](https://docs.cloud.oracle.com/iaas/api/#/en/database/20160918/DbSystemShapeSummary/ListDbSystemShapes) operation.|
| db_admin_password              | A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be _, #, or -.  |
| lb_shape              | A template that determines the total pre-provisioned bandwidth (ingress plus egress). To get a list of available shapes, use the [ListShapes](https://docs.cloud.oracle.com/iaas/api/#/en/loadbalancer/20170115/LoadBalancerShape/ListShapes) operation. Example: 100Mbps  |
| cron_schedule              | Cron schedule of backup/restore of boot/block volumes in Primary region. Example: "0 */12 * * *" this runs every 12 hours. This cron job runs on the bastion server |
| dr_cron_schedule              | Cron schedule of backup/restore of boot/block volumes in Standby region. Example: ""#0 */12 * * *"" this is commented out intentionally as the region is in standby mode. When switchover to this region happens then this should be uncommented  |
| snapshot_frequency              | Cron schedule for taking snapshots of file storage system in Primary region, this is taken on primary_app_server_1. Example "@hourly" for taking hourly snapshots   |
| data_sync_frequency              | Cron schedule for synchronizing the file storage system between both standby and primary region. The rsync job is run as part of this cron scheduler on the compute "dr_replication_server" in standby region. Example "*/30 * * * *" this runs every 30 minutes  |


*Sample terraform.tfvars file to create Hyperion infrastructure in single availability domain architecture*

```
# DR region for standby (us-phoenix-1, ap-seoul-1, ap-tokyo-1, ca-toronto-1)
dr_region = "us-phoenix-1"

# CIDR block of Standby VCN to be created
dr_vcn_cidr_block = "10.0.0.0/16"

# CIDR block of Primary VCN to be created
vcn_cidr_block = "192.168.0.0/16"

# DNS label of VCN to be created
vcn_dns_label = "drvcn"

# Object Storage bucker name (will be prefixed by region name)
bucket_display_name = "bucket-dr"

# Compute shape for bastion server
bastion_server_shape = "VM.Standard2.1"

# Compute shape for application servers
app_server_shape = "VM.Standard2.2"

# Database display name
db_display_name = "ActiveDBSystem"

# Compute shape for Database server
db_system_shape = "VM.Standard2.2"

# DB admin password for database
db_admin_password = "AAbb__111"

# shape for Load Balancer
lb_shape = "100Mbps"

# Cron schedule for Primary region [this runs every 12 hours]
cron_schedule = "0 */12 * * *"

# Cron schedule for Standby region, this is intentionally commented out as the replication job should run only on servers in primary regio [runs every 12 hours]
dr_cron_schedule = "#0 */12 * * *"

#Cron schedule for taking snapshots of file storage system
snapshot_frequency = "@hourly"

#Cron schedule for using rsync in standby region replication server to synchronize
data_sync_frequency	= "*/30 * * * *"
```


## Troubleshooting


### End