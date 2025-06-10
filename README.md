# CATO IPSec Generic Terraform Module 

Terraform module which creates an IPsec site in the Cato Management Application (CMA), and configures the site for tunnels and bgp (If selected).

## NOTE
- For help with finding exact sytax to match site location for city, state_name, country_name and timezone, please refer to the [cato_siteLocation data source](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/siteLocation).
- For help with finding a license id to assign, please refer to the [cato_licensingInfo data source](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/licensingInfo).


## Usage 
### Example 1 - Fully Customized HA without BGP

```hcl
variable "baseurl" {}
variable "token" {}
variable "account_id" {}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

module "ipsec-generic-ha-fully-customized" {
  source                     = "../"
  token                      = var.token
  account_id                 = var.account_id
  ha_tunnels                 = true
  site_name                  = "My-Cato-IPSec-Site-ha"
  site_description           = "IPSec Example Site"
  native_network_range       = "172.16.0.0/24"
  primary_cato_pop_ip        = "x.x.x.x" # Your Primary Cato IP
  secondary_cato_pop_ip      = "y.y.y.y" # Your Secondary Cato IP ID
  cato_local_networks        = ["10.41.0.0/16", "10.254.254.0/24"]
  peer_networks              = ["servers:172.16.0.0/24", "desktops:172.16.1.0/24"]
  peer_primary_public_ip     = "1.1.1.1"
  peer_secondary_public_ip   = "2.2.2.2"
  cato_initMessage_dhGroup   = "DH_21_ECP521"
  cato_initMessage_cipher    = "AES_CBC_256"
  cato_initMessage_integrity = "SHA512"
  cato_initMessage_prf       = "SHA512"
  cato_authMessage_dhGroup   = "DH_21_ECP521"
  cato_authMessage_cipher    = "AES_CBC_256"
  cato_authMessage_integrity = "SHA512"
  cato_connectionMode        = "RESPONDER_ONLY"
  cato_identificationType    = "IPV4"
  downstream_bw              = 100
  upstream_bw                = 100
  site_location = {
    city         = "New York City"
    country_code = "US"
    state_code   = "US-NY"
    timezone     = "America/New_York"
  }
}
```

### Example 2 - Fully Customized HA with BGP

```hcl

variable "baseurl" {}
variable "token" {}
variable "account_id" {}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

module "ipsec-generic-ha-bgp-fully-customized" {
  source                                     = "../"
  token                                      = var.token
  account_id                                 = var.account_id
  ha_tunnels                                 = true
  enable_bgp                                 = true
  site_name                                  = "My-Cato-IPSec-Site-ha-bgp"
  site_description                           = "IPSec Example Site"
  native_network_range                       = "172.16.4.0/24"
  primary_cato_pop_ip                        = "x.x.x.x" # Your Primary Cato IP
  secondary_cato_pop_ip                      = "y.y.y.y" # Your Secondary Cato IP ID
  primary_private_cato_ip                    = "169.254.21.1"
  secondary_private_cato_ip                  = "169.254.22.1"
  primary_private_site_ip                    = "169.254.21.2"
  secondary_private_site_ip                  = "169.254.22.2"
  peer_primary_public_ip                     = "1.1.1.1"
  peer_secondary_public_ip                   = "2.2.2.2"
  peer_bgp_asn                               = 65500
  cato_bgp_asn                               = 65000
  cato_primary_bgp_metric                    = 100
  cato_secondary_bgp_metric                  = 150
  cato_primary_bgp_peer_name                 = "custom-primary-bgp-peer"
  cato_secondary_bgp_peer_name               = "custom-secondary-bgp-peer"
  cato_primary_bgp_advertise_default_route   = true
  cato_secondary_bgp_advertise_default_route = true
  cato_initMessage_dhGroup                   = "DH_21_ECP521"
  cato_initMessage_cipher                    = "AES_CBC_256"
  cato_initMessage_integrity                 = "SHA512"
  cato_initMessage_prf                       = "SHA512"
  cato_authMessage_dhGroup                   = "DH_21_ECP521"
  cato_authMessage_cipher                    = "AES_CBC_256"
  cato_authMessage_integrity                 = "SHA512"
  cato_connectionMode                        = "RESPONDER_ONLY"
  cato_identificationType                    = "IPV4"
  downstream_bw                              = 100
  upstream_bw                                = 100
  site_location = {
    city         = "New York City"
    country_code = "US"
    state_code   = "US-NY"
    timezone     = "America/New_York"
  }
}
```

### Example 3 - Non HA - No BGP - Minimum Parameters

```hcl

variable "baseurl" {}
variable "token" {}
variable "account_id" {}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

module "ipsec-generic-non-ha" {
  source                 = "../"
  token                  = var.token
  account_id             = var.account_id
  ha_tunnels             = false
  site_name              = "My-Cato-IPSec-Site-non-ha"
  site_description       = "IPSec Example Site"
  native_network_range   = "172.16.2.0/24"
  primary_cato_pop_ip    = "x.x.x.x" # Your Primary Cato IP
  cato_local_networks    = ["10.41.0.0/16", "10.254.254.0/24"]
  peer_networks          = ["servers:172.16.2.0/24", "desktops:172.16.3.0/24"]
  peer_primary_public_ip = "1.1.1.1"
  downstream_bw          = 100
  upstream_bw            = 100
  site_location = {
    city         = "New York City"
    country_code = "US"
    state_code   = "US-NY"
    timezone     = "America/New_York"
  }
}
```

### Example 4 - Non HA - BGP - Minimum Parameters

```hcl

variable "baseurl" {}
variable "token" {}
variable "account_id" {}

provider "cato" {
  baseurl    = var.baseurl
  token      = var.token
  account_id = var.account_id
}

module "ipsec-generic-non-ha-bgp" {
  source                  = "../"
  token                   = var.token
  account_id              = var.account_id
  ha_tunnels              = false
  enable_bgp              = true
  site_name               = "My-Cato-IPSec-Site-non-ha-bgp"
  site_description        = "IPSec Example Site"
  native_network_range    = "172.16.5.0/24"
  primary_cato_pop_ip     = "x.x.x.x" # Your Primary Cato IP
  primary_private_cato_ip = "169.254.21.1"
  primary_private_site_ip = "169.254.21.2"
  peer_primary_public_ip  = "1.1.1.1"
  downstream_bw           = 100
  upstream_bw             = 100
  site_location = {
    city         = "New York City"
    country_code = "US"
    state_code   = "US-NY"
    timezone     = "America/New_York"
  }
}

```
## Alloacted IP Reference

You must first [allocate Cato IPs](https://support.catonetworks.com/hc/en-us/articles/4413273467153-Allocating-IP-Addresses-for-the-Account) within the Cato Management Application (CMA).  Depending on whether or not you are deploying with HA (2 IPs) or non-HA (1 IP).


## Site Location Reference

For more information on site_location syntax, use the [Cato CLI](https://github.com/catonetworks/cato-cli) to lookup values.

```bash
$ pip3 install catocli
$ export CATO_TOKEN="your-api-token-here"
$ export CATO_ACCOUNT_ID="your-account-id"
$ catocli query siteLocation -h
$ catocli query siteLocation '{"filters":[{"search": "San Diego","field":"city","operation":"exact"}]}' -p
```

## Authors

Module is maintained by [Cato Networks](https://github.com/catonetworks) with help from [these awesome contributors](https://github.com/catonetworks/terraform-cato-ipsec-generic/graphs/contributors).

## License

Apache 2 Licensed. See [LICENSE](https://github.com/catonetworks/terraform-cato-ipsec-aws/tree/master/LICENSE) for full details.



<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4 |
| <a name="requirement_cato"></a> [cato](#requirement\_cato) | >= 0.0.24 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cato"></a> [cato](#provider\_cato) | >= 0.0.24 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cato_bgp_peer.backup](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/bgp_peer) | resource |
| [cato_bgp_peer.primary](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/bgp_peer) | resource |
| [cato_ipsec_site.ipsec-site](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/ipsec_site) | resource |
| [cato_license.license](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/resources/license) | resource |
| [random_password.shared_key_primary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.shared_key_secondary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [terraform_data.update_ipsec_site_details-bgp](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.update_ipsec_site_details-nobgp](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [cato_allocatedIp.primary](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/allocatedIp) | data source |
| [cato_allocatedIp.secondary](https://registry.terraform.io/providers/catonetworks/cato/latest/docs/data-sources/allocatedIp) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Cato account ID | `number` | n/a | yes |
| <a name="input_baseurl"></a> [baseurl](#input\_baseurl) | Cato API base URL | `string` | `"https://api.catonetworks.com/api/v1/graphql2"` | no |
| <a name="input_cato_authMessage_cipher"></a> [cato\_authMessage\_cipher](#input\_cato\_authMessage\_cipher) | Cato Phase 2 ciphers.  The SA tunnel encryption method. Note: For situations where GCM isn’t supported for the INIT phase, <br/>  we recommend that you use the CBC algorithm for the INIT phase, and GCM for AUTH<br/>  Valid options are: <br/>    AES\_CBC\_128<br/>    AES\_CBC\_256<br/>    AES\_GCM\_128<br/>    AES\_GCM\_256<br/>    AUTOMATIC<br/>    DES3\_CBC<br/>    NONE<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_authMessage_dhGroup"></a> [cato\_authMessage\_dhGroup](#input\_cato\_authMessage\_dhGroup) | Cato Phase 2 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is <br/>   the corresponding prime modulus size in bits<br/>   Valid Options are: <br/>    AUTOMATIC<br/>    DH\_14\_MODP2048<br/>    DH\_15\_MODP3072<br/>    DH\_16\_MODP4096<br/>    DH\_19\_ECP256<br/>    DH\_2\_MODP1024<br/>    DH\_20\_ECP384<br/>    DH\_21\_ECP521<br/>    DH\_5\_MODP1536<br/>    NONE | `string` | `"DH_15_MODP3072"` | no |
| <a name="input_cato_authMessage_integrity"></a> [cato\_authMessage\_integrity](#input\_cato\_authMessage\_integrity) | Cato Phase 2 Hashing Algorithm.  The algorithm used to verify the integrity and authenticity of IPsec packets<br/>    Valid Options are: <br/>    AUTOMATIC<br/>    MD5<br/>    NONE<br/>    SHA1<br/>    SHA256<br/>    SHA384<br/>    SHA512<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_bgp_asn"></a> [cato\_bgp\_asn](#input\_cato\_bgp\_asn) | The BGP Autonomous System Number for the Cato PoPs. Required if azure\_enable\_bgp is true. | `number` | `65001` | no |
| <a name="input_cato_connectionMode"></a> [cato\_connectionMode](#input\_cato\_connectionMode) | Cato Connection Mode.  Determines the protocol for establishing the Security Association (SA) Tunnel. <br/>  Valid values are: Responder-Only Mode: Cato Cloud only responds to incoming requests by the initiator (e.g. a Firewall device) to establish a security association. <br/>  Bidirectional Mode: Both Cato Cloud and the peer device on customer site can initiate the IPSec SA establishment.<br/>  Valid Options are: <br/>    BIDIRECTIONAL<br/>    RESPONDER\_ONLY<br/>    Default to BIDIRECTIONAL | `string` | `"BIDIRECTIONAL"` | no |
| <a name="input_cato_identificationType"></a> [cato\_identificationType](#input\_cato\_identificationType) | Cato Identification Type.  The authentication identification type used for SA authentication. When using “BIDIRECTIONAL”, it is set to “IPv4” by default. <br/>  Other methods are available in Responder mode only. <br/>  Valid Options are: <br/>    EMAIL<br/>    FQDN<br/>    IPV4<br/>    KEY\_ID<br/>    Default to IPV4 | `string` | `"IPV4"` | no |
| <a name="input_cato_initMessage_cipher"></a> [cato\_initMessage\_cipher](#input\_cato\_initMessage\_cipher) | Cato Phase 1 ciphers.  The SA tunnel encryption method. Note: For situations where GCM isn’t supported for the INIT phase, <br/>  we recommend that you use the CBC algorithm for the INIT phase, and GCM for AUTH<br/>  Valid options are: <br/>    AES\_CBC\_128<br/>    AES\_CBC\_256<br/>    AES\_GCM\_128<br/>    AES\_GCM\_256<br/>    AUTOMATIC<br/>    DES3\_CBC<br/>    NONE<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_initMessage_dhGroup"></a> [cato\_initMessage\_dhGroup](#input\_cato\_initMessage\_dhGroup) | Cato Phase 1 DHGroup.  The Diffie-Hellman Group. The first number is the DH-group number, and the second number is <br/>   the corresponding prime modulus size in bits<br/>   Valid Options are: <br/>    AUTOMATIC<br/>    DH\_14\_MODP2048<br/>    DH\_15\_MODP3072<br/>    DH\_16\_MODP4096<br/>    DH\_19\_ECP256<br/>    DH\_2\_MODP1024<br/>    DH\_20\_ECP384<br/>    DH\_21\_ECP521<br/>    DH\_5\_MODP1536<br/>    NONE | `string` | `"DH_15_MODP3072"` | no |
| <a name="input_cato_initMessage_integrity"></a> [cato\_initMessage\_integrity](#input\_cato\_initMessage\_integrity) | Cato Phase 1 Hashing Algorithm.  The algorithm used to verify the integrity and authenticity of IPsec packets<br/>   Valid Options are: <br/>    AUTOMATIC<br/>    MD5<br/>    NONE<br/>    SHA1<br/>    SHA256<br/>    SHA384<br/>    SHA512<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_initMessage_prf"></a> [cato\_initMessage\_prf](#input\_cato\_initMessage\_prf) | Cato Phase 1 Hashing Algorithm for The Pseudo-random function (PRF) used to derive the cryptographic keys used in the SA establishment process. <br/>  Valid Options are: <br/>    AUTOMATIC<br/>    MD5<br/>    NONE<br/>    SHA1<br/>    SHA256<br/>    SHA384<br/>    SHA512<br/>    Default to AUTOMATIC | `string` | `"AUTOMATIC"` | no |
| <a name="input_cato_local_networks"></a> [cato\_local\_networks](#input\_cato\_local\_networks) | If we aren't using BGP, we will need a list of CIDRs which live behind Cato<br/>  for more information https://support.catonetworks.com/hc/en-us/articles/14110195123485-Working-with-the-Cato-System-Range <br/>  Default: ["10.41.0.0/16", "10.254.254.0/24"] | `list(string)` | <pre>[<br/>  "10.41.0.0/16",<br/>  "10.254.254.0/24"<br/>]</pre> | no |
| <a name="input_cato_primary_bgp_advertise_all"></a> [cato\_primary\_bgp\_advertise\_all](#input\_cato\_primary\_bgp\_advertise\_all) | Cato Primary BGP Advertise All | `bool` | `true` | no |
| <a name="input_cato_primary_bgp_advertise_default_route"></a> [cato\_primary\_bgp\_advertise\_default\_route](#input\_cato\_primary\_bgp\_advertise\_default\_route) | Cato Primary BGP Advertise Default Route | `bool` | `false` | no |
| <a name="input_cato_primary_bgp_advertise_summary_route"></a> [cato\_primary\_bgp\_advertise\_summary\_route](#input\_cato\_primary\_bgp\_advertise\_summary\_route) | Cato Primary BGP Advertise Summary Route | `bool` | `false` | no |
| <a name="input_cato_primary_bgp_bfd_multiplier"></a> [cato\_primary\_bgp\_bfd\_multiplier](#input\_cato\_primary\_bgp\_bfd\_multiplier) | Cato Primary BGP BFD Multiplier | `number` | `5` | no |
| <a name="input_cato_primary_bgp_bfd_receive_interval"></a> [cato\_primary\_bgp\_bfd\_receive\_interval](#input\_cato\_primary\_bgp\_bfd\_receive\_interval) | Cato Primary BGP BFD Receive Interval | `number` | `1000` | no |
| <a name="input_cato_primary_bgp_bfd_transmit_interval"></a> [cato\_primary\_bgp\_bfd\_transmit\_interval](#input\_cato\_primary\_bgp\_bfd\_transmit\_interval) | Cato Primary BGP BFD Transmit Interval | `number` | `1000` | no |
| <a name="input_cato_primary_bgp_default_action"></a> [cato\_primary\_bgp\_default\_action](#input\_cato\_primary\_bgp\_default\_action) | Cato Primary BGP Default Action | `string` | `"ACCEPT"` | no |
| <a name="input_cato_primary_bgp_metric"></a> [cato\_primary\_bgp\_metric](#input\_cato\_primary\_bgp\_metric) | Metric for the primary Cato BGP peer to influence route preference. | `number` | `100` | no |
| <a name="input_cato_primary_bgp_peer_name"></a> [cato\_primary\_bgp\_peer\_name](#input\_cato\_primary\_bgp\_peer\_name) | Cato Primary BGP Peer Name | `string` | `null` | no |
| <a name="input_cato_secondary_bgp_advertise_all"></a> [cato\_secondary\_bgp\_advertise\_all](#input\_cato\_secondary\_bgp\_advertise\_all) | Cato Secondary BGP Advertise All | `bool` | `true` | no |
| <a name="input_cato_secondary_bgp_advertise_default_route"></a> [cato\_secondary\_bgp\_advertise\_default\_route](#input\_cato\_secondary\_bgp\_advertise\_default\_route) | Cato Secondary BGP Advertise Default Route | `bool` | `false` | no |
| <a name="input_cato_secondary_bgp_advertise_summary_route"></a> [cato\_secondary\_bgp\_advertise\_summary\_route](#input\_cato\_secondary\_bgp\_advertise\_summary\_route) | Cato Secondary BGP Advertise Summary Route | `bool` | `false` | no |
| <a name="input_cato_secondary_bgp_bfd_multiplier"></a> [cato\_secondary\_bgp\_bfd\_multiplier](#input\_cato\_secondary\_bgp\_bfd\_multiplier) | Cato Secondary BGP BFD Multiplier | `number` | `5` | no |
| <a name="input_cato_secondary_bgp_bfd_receive_interval"></a> [cato\_secondary\_bgp\_bfd\_receive\_interval](#input\_cato\_secondary\_bgp\_bfd\_receive\_interval) | Cato Secondary BGP BFD Receive Interval | `number` | `1000` | no |
| <a name="input_cato_secondary_bgp_bfd_transmit_interval"></a> [cato\_secondary\_bgp\_bfd\_transmit\_interval](#input\_cato\_secondary\_bgp\_bfd\_transmit\_interval) | Cato Secondary BGP BFD Transmit Interval | `number` | `1000` | no |
| <a name="input_cato_secondary_bgp_default_action"></a> [cato\_secondary\_bgp\_default\_action](#input\_cato\_secondary\_bgp\_default\_action) | Cato Secondary BGP Default Action | `string` | `"ACCEPT"` | no |
| <a name="input_cato_secondary_bgp_metric"></a> [cato\_secondary\_bgp\_metric](#input\_cato\_secondary\_bgp\_metric) | Metric for the secondary Cato BGP peer to influence route preference. | `number` | `200` | no |
| <a name="input_cato_secondary_bgp_peer_name"></a> [cato\_secondary\_bgp\_peer\_name](#input\_cato\_secondary\_bgp\_peer\_name) | Cato Secondary BGP Peer Name | `string` | `null` | no |
| <a name="input_downstream_bw"></a> [downstream\_bw](#input\_downstream\_bw) | Downstream bandwidth in Mbps | `number` | n/a | yes |
| <a name="input_enable_bgp"></a> [enable\_bgp](#input\_enable\_bgp) | Enable BGP | `bool` | `false` | no |
| <a name="input_ha_tunnels"></a> [ha\_tunnels](#input\_ha\_tunnels) | Are we building 2 tunnels or 1 tunnel, ha\_tunnels = true when there are two tunnels | `bool` | n/a | yes |
| <a name="input_license_bw"></a> [license\_bw](#input\_license\_bw) | The license bandwidth number for the cato site, specifying bandwidth ONLY applies for pooled licenses.  For a standard site license that is not pooled, leave this value null. Must be a number greater than 0 and an increment of 10. | `string` | `null` | no |
| <a name="input_license_id"></a> [license\_id](#input\_license\_id) | The license ID for the Cato vSocket of license type CATO\_SITE, CATO\_SSE\_SITE, CATO\_PB, CATO\_PB\_SSE.  Example License ID value: 'abcde123-abcd-1234-abcd-abcde1234567'.  Note that licenses are for commercial accounts, and not supported for trial accounts. | `string` | `null` | no |
| <a name="input_native_network_range"></a> [native\_network\_range](#input\_native\_network\_range) | Native network range for the IPSec site | `string` | n/a | yes |
| <a name="input_peer_bgp_asn"></a> [peer\_bgp\_asn](#input\_peer\_bgp\_asn) | The BGP Autonomous System Number for the Azure VPN Gateway. Required if azure\_enable\_bgp is true. | `number` | `65515` | no |
| <a name="input_peer_networks"></a> [peer\_networks](#input\_peer\_networks) | (Optional) List of Networks on the Azure side (if BGP is disabled)<br/>  Examples: <br/>  ["servers:10.0.0.0/24","devices:10.1.0.0/24"] | `list(string)` | `null` | no |
| <a name="input_peer_primary_public_ip"></a> [peer\_primary\_public\_ip](#input\_peer\_primary\_public\_ip) | Primary Tunnel Endpoint IP for Peer Device | `string` | n/a | yes |
| <a name="input_peer_secondary_public_ip"></a> [peer\_secondary\_public\_ip](#input\_peer\_secondary\_public\_ip) | Secondary Tunnel Endpoint IP for Peer Device | `string` | `null` | no |
| <a name="input_primary_cato_pop_ip"></a> [primary\_cato\_pop\_ip](#input\_primary\_cato\_pop\_ip) | The IP address of the primary Cato POP | `string` | n/a | yes |
| <a name="input_primary_connection_shared_key"></a> [primary\_connection\_shared\_key](#input\_primary\_connection\_shared\_key) | Primary connection shared key | `string` | `null` | no |
| <a name="input_primary_destination_type"></a> [primary\_destination\_type](#input\_primary\_destination\_type) | The destination type of the IPsec tunnel | `string` | `null` | no |
| <a name="input_primary_pop_location_id"></a> [primary\_pop\_location\_id](#input\_primary\_pop\_location\_id) | Primary tunnel POP location ID | `string` | `null` | no |
| <a name="input_primary_private_cato_ip"></a> [primary\_private\_cato\_ip](#input\_primary\_private\_cato\_ip) | The BGP peering IP address for the CatoPOP (APIPA). Required if enable\_bgp is true. | `string` | `null` | no |
| <a name="input_primary_private_site_ip"></a> [primary\_private\_site\_ip](#input\_primary\_private\_site\_ip) | The BGP peering IP address for the Azure VPN Gateway (APIPA). Required if enable\_bgp is true. | `string` | `null` | no |
| <a name="input_secondary_cato_pop_ip"></a> [secondary\_cato\_pop\_ip](#input\_secondary\_cato\_pop\_ip) | The IP address of the secondary Cato POP | `string` | `null` | no |
| <a name="input_secondary_connection_shared_key"></a> [secondary\_connection\_shared\_key](#input\_secondary\_connection\_shared\_key) | Secondary connection shared key | `string` | `null` | no |
| <a name="input_secondary_destination_type"></a> [secondary\_destination\_type](#input\_secondary\_destination\_type) | The destination type of the IPsec tunnel | `string` | `null` | no |
| <a name="input_secondary_pop_location_id"></a> [secondary\_pop\_location\_id](#input\_secondary\_pop\_location\_id) | Secondary tunnel POP location ID | `string` | `null` | no |
| <a name="input_secondary_private_cato_ip"></a> [secondary\_private\_cato\_ip](#input\_secondary\_private\_cato\_ip) | The BGP peering IP address for the CatoPOP (APIPA). Required if azure\_enable\_bgp is true.<br/>  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255. | `string` | `null` | no |
| <a name="input_secondary_private_site_ip"></a> [secondary\_private\_site\_ip](#input\_secondary\_private\_site\_ip) | The BGP peering IP address for the Azure VPN Gateway (APIPA). Required if azure\_enable\_bgp is true.<br/>  The valid range for the reserved APIPA address in Azure Public is from 169.254.21.0 to 169.254.22.255. | `string` | `null` | no |
| <a name="input_site_description"></a> [site\_description](#input\_site\_description) | Description of the IPSec site | `string` | n/a | yes |
| <a name="input_site_location"></a> [site\_location](#input\_site\_location) | n/a | <pre>object({<br/>    city         = string<br/>    country_code = string<br/>    state_code   = string<br/>    timezone     = string<br/>  })</pre> | n/a | yes |
| <a name="input_site_name"></a> [site\_name](#input\_site\_name) | Name of the IPSec site | `string` | n/a | yes |
| <a name="input_site_type"></a> [site\_type](#input\_site\_type) | The type of the site | `string` | `"CLOUD_DC"` | no |
| <a name="input_token"></a> [token](#input\_token) | Cato API token | `string` | n/a | yes |
| <a name="input_upstream_bw"></a> [upstream\_bw](#input\_upstream\_bw) | Upstream bandwidth in Mbps | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cato_primary_public_ip"></a> [cato\_primary\_public\_ip](#output\_cato\_primary\_public\_ip) | The Cato public IP address for the primary tunnel. |
| <a name="output_cato_secondary_public_ip"></a> [cato\_secondary\_public\_ip](#output\_cato\_secondary\_public\_ip) | The Cato public IP address for the secondary tunnel (if HA is enabled). |
| <a name="output_ipsec_site_configuration_details"></a> [ipsec\_site\_configuration\_details](#output\_ipsec\_site\_configuration\_details) | Detailed configuration of the IPsec site. |
| <a name="output_ipsec_site_id"></a> [ipsec\_site\_id](#output\_ipsec\_site\_id) | The ID of the created Cato IPsec site. |
| <a name="output_license_assignment_id"></a> [license\_assignment\_id](#output\_license\_assignment\_id) | The ID of the license assignment, if a license was assigned. |
| <a name="output_primary_bgp_peer_id"></a> [primary\_bgp\_peer\_id](#output\_primary\_bgp\_peer\_id) | The ID of the primary BGP peer, if BGP is enabled. |
| <a name="output_primary_tunnel_psk"></a> [primary\_tunnel\_psk](#output\_primary\_tunnel\_psk) | The pre-shared key for the primary IPsec tunnel. This is sensitive and will be the generated key if not provided as an input. |
| <a name="output_random_primary_shared_key_result"></a> [random\_primary\_shared\_key\_result](#output\_random\_primary\_shared\_key\_result) | The randomly generated primary shared key. Only populated if a primary\_connection\_shared\_key was not provided. |
| <a name="output_random_secondary_shared_key_result"></a> [random\_secondary\_shared\_key\_result](#output\_random\_secondary\_shared\_key\_result) | The randomly generated secondary shared key. Only populated if a secondary\_connection\_shared\_key was not provided and HA tunnels are enabled. |
| <a name="output_secondary_bgp_peer_id"></a> [secondary\_bgp\_peer\_id](#output\_secondary\_bgp\_peer\_id) | The ID of the secondary BGP peer, if BGP and HA are enabled. |
| <a name="output_secondary_tunnel_psk"></a> [secondary\_tunnel\_psk](#output\_secondary\_tunnel\_psk) | The pre-shared key for the secondary IPsec tunnel if HA is enabled. This is sensitive and will be the generated key if not provided as an input. |
<!-- END_TF_DOCS -->