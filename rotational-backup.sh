#!/bin/bash

# Check if the number of arguments is correct
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <source dir> <destination dir of local storage> <s3 bucket url (it's optional) >"
    echo "Example 1: $0 /var/www/html/ ~/backup/ s3://mybucket/myBackupDir/"
    echo "Example 2(without s3 path): $0 /var/www/html/ ~/backup/"
    exit 1
fi


src_dir="$1"
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
des_dir="$2"
s3_bucket="$3"

# Print the destination directory
echo "Destination Directory: $des_dir"

# Create backup directory if it doesn't exist
mkdir -p $2

# Install zip if not already installed
if ! command -v zip &> /dev/null; then
    echo "zip command not found. Installing..."
    sudo apt install zip -y
fi

# Take backup using zip utility and assing sufficent permssions
mkdir -p ~/backup 
zip -r "$des_dir/backup_$timestamp.zip" "$src_dir"

if [ $? -eq 0 ]; then
    echo "[+] Backup has been taken to $des_dir at $timestamp" | tee -a ~/backup/log.txt 
else
    echo "[-] Failed to take backup to $des_dir at $timestamp" | tee -a ~/backup/log.txt 
    exit 1
fi

chmod 700 "$des_dir/backup_$timestamp.zip"

if [ -n "$s3_bucket" ]; then
	echo "[+] Uploading backup to s3 bucket... "
	aws s3 cp "$des_dir/backup_$timestamp.zip" "$s3_bucket" 
fi

if [ $? -eq 0 ]; then
    echo "[+] Backup has been uploaded to $s3_bucket at $timestamp" | tee -a ~/backup/log.txt 
else
    echo "[-] Failed to upload to $s3_bucket at $timestamp" | tee -a ~/backup/log.txt 
    exit 1
fi 

# rotation - the below code will keep latest 3 backups and will delete rest of all backups

backups=($(ls -t "${des_dir}"/backup_* 2>/dev/null))

# Check if there are more than 3 backups
if [ "${#backups[@]}" -gt 3 ]; then
    echo "Performing rotation for 3 days"
    backups_to_remove=("${backups[@]:3}")

    for backup in "${backups_to_remove[@]}"; do
        
        rm -f "${backup}"
        
        if [ $? -eq 0 ]; then 
        	echo "[+] Deleted backup: ${backup}" | tee -a ~/backup/log.txt 
        else
        	echo "[-] Someting went wrong while deleting ${backup}" | tee -a ~/backup/log.txt 
        fi
        
        if [ -n "$s3_bucket" ]; then
        
        	s3_backup_path="${s3_bucket}$(basename ${backup})"
            	aws s3 rm "$s3_backup_path"
        
        	if [ $? -eq 0 ]; then
        		echo "[+] Deleted backup from S3: $s3_backup_path" | tee -a ~/backup/log.txt 
        	else
        		echo "[-] Someting went wrong while deleting backup from S3: $s3_backup_path" | tee -a ~/backup/log.txt 
       		fi
       	fi
        
        
    done
else
    echo "No rotation needed. Found ${#backups[@]} backups."
fi
