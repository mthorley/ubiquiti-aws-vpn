# Ubiquiti AWS VPN 
Basic Terraform for provisioning VPN connectivity between Ubiquiti Unifi Security Gateway and AWS site to site VPN connection. Its possible this may also work for Edge routers also running EdgeOS but this has not been tested.

## How It Works
Uses Terraform to 
* Create a VPC with a site to site VPN configuration and deploys an example syslog EC2 instance
* Generate shell scripts to configure Unifi USG to connect to AWS

Key points
* For simplicity, [uses BGP rather than static routes](https://medium.com/@silasthomas/aws-vpc-ipsec-site-to-site-vpn-using-a-ubiquiti-edgemax-edgerouter-with-bgp-routing-37abafb950f3)
* Currently only establishes a single tunnel 
* VPN configuration is based on Vyatta configuration exported from AWS Console site to site 

## Setup
Two things
* Configure variables specifying credentials and the network 
* Create keys to support automation

### Configuration
Ensure terraform.tfvars contains the following configuration:

| Param             | Description   | Example |
| ------------------|---------------|---------|
| usg_priv_key_path | Path to Unifi USG device | ~/.ssh/id_rsa | 
| usg_admin_user    | Administrator username of USG | administrator   |
| usg_ip            | IP address of USG device | 192.168.1.1 |
| env               | Namespace for environment | dev, prod | 
| prod_access_key   | AWS API access key        | |
| prod_secret_key   | AWS API secret key        | | 
| vpc_cidr          | CIDR block for VPC        | 172.16.0.0/16 |
| sn1_cidr          | CIDR block for subnet 1   | 172.16.0.0/24 |
| sn2_cidr          | CIDR block for subnet 2   | 172.16.32.0/24 |
| aws_bgp_asn       | BGP ASN for AWS side      | 64513 |
| usg_bgp_asn       | BGP ASN for USG side      | 65001 |
| wan_ip            | Public IP of USG          | |
| usg_cidr          | CIDR block for USG network | 192.168.0.1/24 |

### Keys
[SSH keys to authenticate with Unifi/Edge devices](https://help.ubnt.com/hc/en-us/articles/235247068-UniFi-Adding-SSH-Keys-to-UniFi-Devices#2)

Generate AWS API keys, create an IAM user (e.g terraform) with following AWS managed policies attached
* AmazonEC2FullAccess
* AmazonVPCFullAccess
* AWSMarketplaceRead-only

## Usage
```
terraform apply
```
and magic should happen.

## Future Work

* [Align the generated shell scripts to Ubiquiti commands](https://help.ubnt.com/hc/en-us/articles/115016128008-EdgeRouter-IPsec-Route-Based-Site-to-Site-VPN-to-AWS-VPC-BGP-over-IKEv1-IPsec-) rather than AWS Vyatta config.
* Put ALB infront of syslog EC2 instance to redundancy and consistent endpoint for syslog clients.
