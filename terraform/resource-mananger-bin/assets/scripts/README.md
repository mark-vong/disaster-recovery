# dr-automation-scripts

Repository to create automation scripts for disaster recovery

Boot Volume & Block Volume Automation script:

1.   Boot Volume script (boot-volume-migration.py) takes all volume from one region for a given compartment and restores this volume across any given region thru volume backups

usage: boot-volume-migration.py [-h] 
			--compartment-id COMPARTMENT_ID

            --destination-region DESTINATION_REGION

2. Block Volume script (block-volume-migration.py) takes all volume from one region for a given compartment and restores this volume across any given region thru volume backups

usage: block-volume-migration.py [-h] 
			 --compartment-id COMPARTMENT_ID

             --destination-region DESTINATION_REGION


Steps in the automation scripts:
1. create_volume_backups in source region
2. copy_volume_backups across destination region
3. restore_volume in destination region