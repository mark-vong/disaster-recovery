#Copyright © 2020, Oracle and/or its affiliates.
#The Universal Permissive License (UPL), Version 1.0
#changes

#ssh keys paths
# ssh_public_key_file = "./keys/id_rsa.pub"
# ssh_private_key_file = "./keys/id_rsa"

# DB admin password for database
# db_admin_password = "Welcome123"

# shape for Load Balancer
lb_shape = "400Mbps"

# Cron schedule for Primary region [this runs every 12 hours]
# cron_schedule = "0 */24 * * *"

# Cron schedule for Standby region, this is intentionally commented out as the replication job should run only on servers in primary regio [runs every 12 hours]
# dr_cron_schedule = "#0 */6 * * *"

# Cron schedule for taking snapshots of file storage system
# snapshot_frequency = "*/60 * * * *"

# Cron schedule for using rsync in standby region replication server to synchronize
# data_sync_frequency	= "*/60 * * * *"



