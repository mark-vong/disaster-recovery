# Oracle’s Cloud Platform: Disaster Recovery

<!-- Comment out table of contents
## Table of Contents
[Introduction](#introduction)
-->

## Introduction

![Alt text](./failover_SS.png?raw=true "Title")

### Objectives
- automate block volume backups to new region
- setup DNS on OCI
- simulate disaster and subsequent recovery

### Documentation
- [Traffic Management on OCI](https://www.oracle.com/a/ocom/docs/cloud/traffic-management-100.pdf)
- [Block Volume Backups](https://docs.cloud.oracle.com/en-us/iaas/Content/Block/Concepts/blockvolumebackups.htm)
- [Installing Terraform](https://docs.cloud.oracle.com/en-us/iaas/Content/API/SDKDocs/terraformgetstarted.htm)

### [Lab100: Setup your Environment](https://github.com/arshyasharifian/DR_DNS/blob/master/Lab100/LabGuide100.md)
- Use attached Terraform scripts to provision the environment
- Complete standby region load balancer setup in OCI console
- Configure DNS for home region
  
### [Lab200: Configure Failover & Recovery Backups](https://github.com/arshyasharifian/DR_DNS/blob/master/LabGuide200.md)
- Configure DNS failover to standby region in traffic management
- Run attached Python scripts to take backups and move them from primary to standby region
- Restore a backup from the Primary region to compute in the standby region

### [Lab300: Simulate Disaster](https://github.com/arshyasharifian/DR_DNS/blob/master/LabGuide300.md)
- Drain connections in Primary load balancer
- Show DNS failover to standby region
- Scale up compute node in standby region
