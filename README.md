# SSH File Transfer Script

This Bash script allows you to efficiently search for files on a remote server using SSH and copy them to your local machine while preserving their directory structure. It supports both `rsync` and `scp` for flexible file transfer options.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
  - [Options](#options)
- [Example](#example)
- [License](#license)

## Features

- Easily search for files matching specific patterns on a remote server.
- Seamlessly copy files to your local machine while retaining their directory structure.
- Flexible support for both `rsync` and `scp` for file transfer.

## Prerequisites

Before using this script, ensure you have the following prerequisites installed on your local machine:

- Bash (usually pre-installed on most Linux distributions and macOS)
- SSH (Secure Shell)
- `rsync` (optional, required for better performance)

## Installation

1. Clone the repository or download the script to your local machine.

   ```shell
   git clone https://github.com/Popwers/ssh-file-transfer.git
   ```
2. Make the script executable:

   ```shell
    cd ssh-file-transfer
    chmod +x ssh_file_transfer.sh
    ```

You're now ready to use the script!

### Usage

The script allows you to copy files from a remote server to a local directory while specifying a file pattern to search for. Use the following command to run the script:

```shell
./ssh_file_transfer.sh -i <ssh_private_key> -u <remote_user> -s <remote_server> -d <local_directory> -f <file_pattern>
```

### Options
- -i: SSH private key file (required).
- -u: Remote user (required).
- -s: Remote server address (required).
- -d: Local directory where files will be copied (required).
- -f: File pattern to search for (required).

## Example

Here's an example of how to use the script:

```shell
./ssh_file_transfer.sh -i ~/.ssh/your-ssh-key.pem -u ec2-user -s ec2-xxx-xxx-xxx-xxx.compute.amazonaws.com -d ~/local_directory -f '.env*'
```

This command will search for files matching the pattern '.env*' on the remote server and copy them to the local directory while preserving their directory structure.

## License

This script is licensed under the MIT License. See the LICENSE file for details.
