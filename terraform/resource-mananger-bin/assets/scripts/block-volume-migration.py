# coding: utf-8
# Copyright (c) 2016, 2020, Oracle and/or its affiliates. All rights reserved.
import oci
import argparse
import datetime


def create_volume_backups(bs_client, compartment_id):
	bv_list = []
	# List the volumes
	volumes = bs_client.list_volumes(compartment_id).data
	# Create Backup Volume of the listed volumes
	bv_request = oci.core.models.CreateVolumeBackupDetails()
	for v in range(len(volumes)):
		bv_request.volume_id = volumes[v].id
		bv_request.type = bv_request.TYPE_INCREMENTAL
		bv_request.display_name = "backup_" + volumes[v].display_name

		if (volumes[v].lifecycle_state == 'AVAILABLE'):
			print("creating backup of volume id: ", volumes[v].id)
			bv_response = bs_client.create_volume_backup(bv_request, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
			oci.wait_until(bs_client, bs_client.get_volume_backup(bv_response.data.id), 'lifecycle_state', 'AVAILABLE')
			bv_list.append(bv_response.data.id)
	print("Created Block Storage Volume Backups {}".format(bv_list))
	return bv_list

# Copy Block Volume Backups to destination region
def copy_volume_backups(bs_client, backup_volume_list, destination_client, destination_region):
	copy_volume_backup_request = oci.core.models.CopyVolumeBackupDetails()
	copy_volume_backup_request.destination_region = destination_region
	
	dest_backup_volume_list = []
	for bv in range(len(backup_volume_list)):
		print(backup_volume_list[bv])
		print("copy started for volume backup id: {}".format(backup_volume_list[bv]))

		copy_response = bs_client.copy_volume_backup(backup_volume_list[bv], copy_volume_backup_request, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
		oci.wait_until(destination_client, destination_client.get_volume_backup(copy_response.data.id), 'lifecycle_state', 'AVAILABLE')
		dest_backup_volume_list.append(copy_response.data.id)
	print("Volume Backups copied succesfully {}".format(dest_backup_volume_list))
	return dest_backup_volume_list

# Restore Block Volume from the copied backups in destination region
def restore_volume(destination_client, dest_backup_volume_list, _compartment_id, _availability_domain):
	current_time = datetime.datetime.now()
	restore_volume_backup_request = oci.core.models.CreateVolumeDetails()
	restore_volume_backup_request.compartment_id = _compartment_id
	restore_volume_backup_request.availability_domain = _availability_domain

	dest_volume_list = []
	for bv in range(len(dest_backup_volume_list)):
		restore_volume_backup_request.source_details = oci.core.models.VolumeSourceFromVolumeBackupDetails(
			id = dest_backup_volume_list[bv],
			type = "volumeBackup"
		)
		backup_volume = destination_client.get_volume_backup(dest_backup_volume_list[bv])
		restore_volume_backup_request.display_name = backup_volume.data.display_name.partition("_")[2] + "-" + str(current_time.day) + str(current_time.hour) + str(current_time.minute)	

		restore_volume_response = destination_client.create_volume(restore_volume_backup_request, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
		oci.wait_until(destination_client, destination_client.get_volume(restore_volume_response.data.id), 'lifecycle_state', 'AVAILABLE')
		dest_volume_list.append(restore_volume_response.data.id)
	print("Volumes restored succesfully {}".format(dest_volume_list))	


# Main Block
if __name__ == "__main__":
	# parse arguments
	parser = argparse.ArgumentParser(description='''This script will copy block volume across regions. ''',
    epilog="""Oracle Cloud Infrastructure.""")
	parser.add_argument('--compartment-id',
                    	help='the OCID of the compartment',
                    	required=True
                    	)
	parser.add_argument('--destination-region',
                    	help='the name of the destination region',
                    	required=True
                    	)
	args = parser.parse_args()
	_compartment_id = args.compartment_id
	_destination_region = args.destination_region

	# Set up config
	try:
            # get signer from instance principals token
            source_signer = oci.auth.signers.InstancePrincipalsSecurityTokenSigner()
	except Exception:
	    print("There was an error while trying to get the Signer")
	    raise SystemExit
	source_config = {'region': source_signer.region, 'tenancy': source_signer.tenancy_id}
	destination_config = {'region': _destination_region, 'tenancy': source_signer.tenancy_id}

    # Initialize the client
	identity_client = oci.identity.IdentityClient(config = source_config, signer=source_signer)
	source_client = oci.core.BlockstorageClient(config = source_config, signer=source_signer)

	destination_identity_client = oci.identity.IdentityClient(config = destination_config, signer=source_signer)
	destination_client = oci.core.BlockstorageClient(config = destination_config, signer=source_signer)

	destination_availability_domain_list = destination_identity_client.list_availability_domains(_compartment_id)

	# Call methods to perform backup, copy & restore
	backup_volume_list = create_volume_backups(source_client, _compartment_id)
	dest_backup_volume_list = copy_volume_backups(source_client, backup_volume_list, destination_client, _destination_region)
	restore_volume(destination_client, dest_backup_volume_list, _compartment_id, destination_availability_domain_list.data[0].name)

	print("Block Volume replication across region completed succesfully")
