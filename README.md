# 📦 Rotational-backup.sh

This Bash script automates the process of creating backups of a specified directory, storing them locally, and optionally uploading them to an S3 bucket. It also includes functionality to keep only the latest 3 backups and delete the older ones. The script also stores logs in a default directory `~/backup/log.txt` so that users can check for errors and events.

## 📖 Usage
```
 bash ./backup.sh <source dir> <destination dir of local storage> <s3 bucket url (optional argument)>
```
### 💡 Examples

1.  Backup to a local directory and upload to an S3 bucket:
```
./rotational-backup.sh /var/www/html/ ~/backup/ s3://mybucket/myBackupDir/
```
2. Backup to a local directory only:
```
./backup.sh /var/www/html/ ~/backup/
```
## 📋 Arguments

-   `<source dir>`: The source directory to be backed up.
-   `<destination dir of local storage>`: The local directory where the backup will be stored.
-   `<s3 bucket url>`: (Optional) The S3 bucket URL where the backup will be uploaded (don't forget to configure aws-cli with an account that has sufficient permissions).

## 📥 Prerequisites

-   **AWS CLI**: Ensure the AWS CLI is installed and configured with the necessary permissions to access the S3 bucket.
-   **zip**: The `zip` utility is required for creating compressed backups.
- **basename**: This package is required to fix the upload/deletion path of s3

## 📜 Script Details

1.  **🔍 Argument Validation**:
    
    -   Ensures the correct number of arguments are provided.
2.  **📦 Variable Initialization**:
    
    -   Sets the source directory, destination directory, and timestamp for the backup.
3.  **📁 Directory Creation**:
    
    -   Creates the destination directory if it doesn't exist.
    -   Ensures the `~/backup` directory exists for logging.
4.  **⚙️ Install `zip` Utility**:
    
    -   Checks if the `zip` command is available, and installs it if necessary.
5.  **💾 Creating the Backup**:
    
    -   Uses `zip` to create a compressed archive of the source directory.
    -   Sets appropriate permissions for the backup file.
6.  **📝 Logging**:
    
    -   Logs the success or failure of the backup operation to `~/backup/log.txt`.
7.  **☁️ S3 Upload (Optional)**:
    
    -   If an S3 bucket URL is provided, uploads the backup file to the specified S3 bucket.
    -   Logs the success or failure of the upload operation.
8.  **🔄 Backup Rotation**:

    The script performs backup rotation to keep the latest 3 backups and delete older ones:

-   Lists all backup files in the destination directory.
-   If there are more than 3 backups, deletes the older ones locally.
-   If an S3 bucket URL is provided, also deletes the corresponding backups from the S3 bucket.
