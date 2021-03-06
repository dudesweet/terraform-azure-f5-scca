# Deploying BIG-IP VEs in Azure - ConfigSync Cluster (Active/Standby): Two NICs

## Contents

- [Deploying BIG-IP VEs in Azure - ConfigSync Cluster (Active/Standby): Two NICs](#deploying-big-ip-ves-in-azure---configsync-cluster-activestandby-two-nics)
  - [Contents](#contents)
  - [Introduction](#introduction)
  - [Prerequisites](#prerequisites)
  - [Important configuration notes](#important-configuration-notes)
  - [docker](#docker)
    - [requirements](#requirements)

## Introduction

This solution uses an Terraform template to launch a three NIC deployment of a cloud-focused BIG-IP VE cluster (Active/Standby) in Microsoft Azure. Traffic flows from an ALB to the BIG-IP VE which then processes the traffic to application servers. This is the standard cloud design where the BIG-IP VE instance is running with a dual interface, where both management and data plane traffic is processed on each one.

The BIG-IP VEs have the following modules enabled:
* [Local Traffic Manager (LTM)](https://f5.com/products/big-ip/local-traffic-manager-ltm) module enabled to provide advanced traffic management functionality.
* Firewall
* WAF
* Whatever

The one big thing in this Terraform accounted for is composing resources a bit differently to account for dependencies into Immutable/Mutable elements. i.e. stuff you would typically frequently change/mutate, such as traditional config on the BIG-IP. Once the template is deployed, there are certain resources (like the network infrastructure) that are fixed while others (like BIG-IP VMs and configurations) can be changed.

Ex.
-> Run once
- Deploy the entire infrastructure with all the neccessary resources, then we use Declarative Onboarding to configure the BIG-IP Cluster; AS3 to create a sample app proxy; then lastly use Service Discovery automatically add the DVWA container app to the LTM pool (Please note currently we also hardcode the node IP in the pool due to a bug in our AS3, which will be fixed in the next release)

-> Run many X
- [Redeploy BIG-IP for replacement or upgrade](#Redeploy-BIG-IP-for-replacement-or-upgrade)
- [Reconfigure BIG-IP configurations](#Rerun-AS3-on-the-big-ip-ve)

**Networking Stack Type:** This solution deploys into a new networking stack, which is created along with the solution.

## Prerequisites

- **Important**: When you configure the admin password for the BIG-IP VE in the template, you cannot use the character **#**.  Additionally, there are a number of other special characters that you should avoid using for F5 product user accounts.  See [K2873](https://support.f5.com/csp/article/K2873) for details.
- This template requires a service principal, one will be created in the setupAzureVars.sh.  See the [Service Principal Setup section](#service-principal-authentication) for details, including required permissions.
- This deployment will be using the Terraform Azurerm provider to build out all the neccessary Azure objects. Therefore, Azure CLI is required. for installation, please follow this [Microsoft link](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
- If this is the first time to deploy the F5 image, the subscription used in this deployment needs to be enabled to programatically deploy. For more information, please refer to [Configure Programatic Deployment](https://azure.microsoft.com/en-us/blog/working-with-marketplace-images-on-azure-resource-manager/)
- You need to set your region and log in to azure ahead of time, the scripts will map your authenitcation credentials and create a service principle, so you will not need to hardcode any credentials in the files.

## Important configuration notes

- All variables are configured in variables.tf
## variables
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13 |
| azurerm | ~> 2.15.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 2.15.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| adminPassword | n/a | `string` | `"pleaseUseVault123!!"` | no |
| adminUserName | n/a | `string` | `"xadmin"` | no |
| app01ip | Example application private ips | `string` | `"10.90.2.101"` | no |
| application | n/a | `string` | `"f5app"` | no |
| asm\_policy | # ASM Policy #  -Examples:  https://github.com/f5devcentral/f5-asm-policy-templates #  -Default is using OWASP Ready Autotuning | `string` | `"https://raw.githubusercontent.com/f5devcentral/f5-asm-policy-templates/master/owasp_ready_template/owasp-auto-tune-v1.1.xml"` | no |
| bigip\_version | n/a | `string` | `"latest"` | no |
| cidr | NETWORK | `string` | `"10.90.0.0/16"` | no |
| costcenter | n/a | `string` | `"f5costcenter"` | no |
| deploymentType | one\_tier or three\_tier | `string` | `"one_tier"` | no |
| dns\_server | n/a | `string` | `"8.8.8.8,8.8.4.4"` | no |
| environment | n/a | `string` | `"f5env"` | no |
| f5vm01ext | bigip external private ips | `string` | `"10.90.1.4"` | no |
| f5vm01ext\_sec | n/a | `string` | `"10.90.1.11"` | no |
| f5vm01int | bigip internal private ips | `string` | `"10.90.2.4"` | no |
| f5vm01int\_sec | n/a | `string` | `"10.90.2.11"` | no |
| f5vm01mgmt | bigip mgmt private ips | `string` | `"10.90.0.4"` | no |
| f5vm02ext | n/a | `string` | `"10.90.1.5"` | no |
| f5vm02ext\_sec | n/a | `string` | `"10.90.1.12"` | no |
| f5vm02int | n/a | `string` | `"10.90.2.5"` | no |
| f5vm02int\_sec | n/a | `string` | `"10.90.2.12"` | no |
| f5vm02mgmt | n/a | `string` | `"10.90.0.5"` | no |
| f5vm03ext | n/a | `string` | `"10.90.6.4"` | no |
| f5vm03ext\_sec | n/a | `string` | `"10.90.6.11"` | no |
| f5vm03int | n/a | `string` | `"10.90.7.4"` | no |
| f5vm03mgmt | n/a | `string` | `"10.90.0.6"` | no |
| f5vm04ext | n/a | `string` | `"10.90.6.5"` | no |
| f5vm04ext\_sec | n/a | `string` | `"10.90.6.12"` | no |
| f5vm04int | n/a | `string` | `"10.90.7.5"` | no |
| f5vm04mgmt | n/a | `string` | `"10.90.0.7"` | no |
| group | n/a | `string` | `"f5group"` | no |
| host1\_name | n/a | `string` | `"f5vm01"` | no |
| host2\_name | n/a | `string` | `"f5vm02"` | no |
| host3\_name | n/a | `string` | `"f5vm03"` | no |
| host4\_name | n/a | `string` | `"f5vm04"` | no |
| ilb01ip | azure internal load balancer | `string` | `"10.90.2.10"` | no |
| image\_name | BIGIP Image check available image names with az cli: az vm image list --output table --publisher f5-networks --location usgovvirginia --offer f5-big-ip --all | `string` | `"f5-bigip-virtual-edition-25m-best-hourly"` | no |
| instanceType | device | `string` | `"Standard_DS5_v2"` | no |
| ips01ext | Example IPS private ips | `string` | `"10.90.4.4"` | no |
| ips01int | n/a | `string` | `"10.90.5.4"` | no |
| jumpinstanceType | Be careful which instance type selected, jump boxes currently use Premium\_LRS managed disks | `string` | `"Standard_B2s"` | no |
| licenses | BIGIP Setup | `map(string)` | <pre>{<br>  "license1": "",<br>  "license2": "",<br>  "license3": "",<br>  "license4": ""<br>}</pre> | no |
| linuxjumpip | linuxjump | `string` | `"10.90.3.99"` | no |
| location | n/a | `string` | `"usgovvirginia"` | no |
| ntp\_server | n/a | `string` | `"time.nist.gov,0.us.pool.ntp.org"` | no |
| onboard\_log | n/a | `string` | `"/var/log/startup-script.log"` | no |
| owner | n/a | `string` | `"f5owner"` | no |
| product | n/a | `string` | `"f5-big-ip-best"` | no |
| projectPrefix | Azure Environment | `string` | `"mcscca"` | no |
| purpose | TAGS | `string` | `"public"` | no |
| region | n/a | `string` | `"USGov Virginia"` | no |
| sshPublicKey | ssh public key for instances | `string` | `""` | no |
| sshPublicKeyPath | n/a | `string` | `"/mykey.pub"` | no |
| subnets | n/a | `map(string)` | <pre>{<br>  "external": "10.90.1.0/24",<br>  "inspect_ext": "10.90.4.0/24",<br>  "inspect_int": "10.90.5.0/24",<br>  "internal": "10.90.2.0/24",<br>  "management": "10.90.0.0/24",<br>  "vdms": "10.90.3.0/24",<br>  "waf_ext": "10.90.6.0/24",<br>  "waf_int": "10.90.7.0/24"<br>}</pre> | no |
| timezone | n/a | `string` | `"UTC"` | no |
| winjumpip | winjump | `string` | `"10.90.3.98"` | no |

## Outputs

| Name | Description |
|------|-------------|
| ALB\_app1\_pip | output ALB\_app1\_pip { value = data.azurerm\_public\_ip.lbpip.ip\_address } |
| sg\_id | n/a |
| sg\_name | n/a |
| tier\_one | single tier |
| tier\_three | three tier |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Development
Outline any requirements to setup a development environment if someone would like to contribute.  You may also link to another file for this information.

  ```bash
  # test pre commit manually
  pre-commit run -a -v
  ```
