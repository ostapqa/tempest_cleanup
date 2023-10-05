# OpenStack Tempest Cleanup Script

This script automates the cleanup of OpenStack resources created during testing via Tempest framework, using the OpenStack CLI.

## Prerequisites

1. **OpenStack CLI**: Ensure you have the OpenStack CLI (`openstack`) installed and configured on your system.

2. **Clone this repository**: Clone this repository to your local machine.

3. **Source File with Credentials**: Prepare a source file containing the credentials for the OpenStack CLI. This file should set the necessary environment variables for authentication. For example:

   ```bash
   # Example source file content
   export OS_USERNAME="your_username"
   export OS_PASSWORD="your_password"
   export OS_PROJECT_NAME="your_project_name"
   export OS_AUTH_URL="your_auth_url"
   export OS_USER_DOMAIN_NAME="Default"
   export OS_PROJECT_DOMAIN_NAME="Default"

## Usage
Run the cleanup script by providing the path to the source file as a bash parameter:
```sh
bash tempest_cleanup.sh <path_to_source_file>
```

Replace <path_to_source_file> with the actual path to your source file containing OpenStack credentials.

The script will use the provided credentials to clean up various OpenStack resources, such as servers, floating IPs, ports, subnets, security groups, networks, volumes, and flavors created during testing.

## Sequence of Cleanup
The sequence of clean up entities is as follows:

> 1. Servers
> 2. Floating IPs (FIPs)
> 3. Ports
> 4. Routers
> 5. Security Groups
> 6. Subnets
> 7. Networks
> 8. Volumes
> 9. Volume Types
> 10. Flavors
> 11. Images
> 12. Keypairs
