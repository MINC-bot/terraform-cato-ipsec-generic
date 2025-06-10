resource "random_password" "shared_key_primary" {
  length  = 32
  special = true
}

resource "random_password" "shared_key_secondary" {
  length  = 32
  special = true
}

# Create Cato ipsec site and tunnels
resource "cato_ipsec_site" "ipsec-site" {
  name                 = var.site_name
  site_type            = var.site_type
  description          = var.site_description
  native_network_range = var.native_network_range
  site_location        = var.site_location
  ipsec = {
    primary = {
      destination_type  = var.primary_destination_type
      public_cato_ip_id = data.cato_allocatedIp.primary[0].items[0].id
      pop_location_id   = var.primary_pop_location_id
      tunnels = [
        {
          public_site_ip  = var.peer_primary_public_ip
          private_cato_ip = var.enable_bgp ? var.primary_private_cato_ip : null
          private_site_ip = var.enable_bgp ? var.primary_private_site_ip : null

          psk = var.primary_connection_shared_key == null ? random_password.shared_key_primary.result : var.primary_connection_shared_key
          last_mile_bw = {
            downstream = var.downstream_bw
            upstream   = var.upstream_bw
          }
        }
      ]
    }
    secondary = var.ha_tunnels ? {
      destination_type  = var.secondary_destination_type
      public_cato_ip_id = var.ha_tunnels ? data.cato_allocatedIp.secondary[0].items[0].id : null
      pop_location_id   = var.secondary_pop_location_id
      tunnels = [
        {
          public_site_ip  = var.peer_secondary_public_ip
          private_cato_ip = var.enable_bgp ? var.secondary_private_cato_ip : null
          private_site_ip = var.enable_bgp ? var.secondary_private_site_ip : null
          psk             = var.secondary_connection_shared_key == null ? random_password.shared_key_secondary.result : var.secondary_connection_shared_key
          last_mile_bw = {
            downstream = var.downstream_bw
            upstream   = var.upstream_bw
          }
        }
      ]
    } : null
  }
}

# The Following 'terraform_data' resources allow us to set the specifics of the 
# IPSEC configuration within Cato.  The Resource for this is being built, however, 
# we need to set all of the information to make this module useful, especially 
# when we aren't doing bgp and need to set the remote networks, or when default
# P1 & P2 settings don't match out of the box. (Like W/ Azure and DHGroup 14).

resource "terraform_data" "update_ipsec_site_details-bgp" {
  #Null Resource has been replaced by "terraform_data"
  depends_on = [cato_ipsec_site.ipsec-site]
  count      = var.enable_bgp ? 1 : 0

  triggers_replace = [
    cato_ipsec_site.ipsec-site.id,
    var.cato_authMessage_integrity,
    var.cato_authMessage_cipher,
    var.cato_authMessage_dhGroup,
    var.cato_initMessage_prf,
    var.cato_initMessage_integrity,
    var.cato_initMessage_cipher,
    var.cato_initMessage_dhGroup,
    var.cato_connectionMode
  ]

  provisioner "local-exec" {
    # This command uses a 'heredoc' to pipe the rendered JSON template
    # directly into curl's standard input.
    # The '--data @-' argument tells curl to read the POST data from stdin.
    # For Debugging the API Call, add '-v' to the curl statement before the '-k'
    command = <<EOT
cat <<'PAYLOAD' | curl -k -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'x-API-Key: ${var.token}' '${var.baseurl}' --data @-
${templatefile("${path.module}/templates/update_site_payload.json.tftpl", {
    account_id      = var.account_id
    site_id         = cato_ipsec_site.ipsec-site.id
    connection_mode = var.cato_connectionMode
    init_dh_group   = var.cato_initMessage_dhGroup
    init_cipher     = var.cato_initMessage_cipher
    init_integrity  = var.cato_initMessage_integrity
    init_prf        = var.cato_initMessage_prf
    auth_dh_group   = var.cato_authMessage_dhGroup
    auth_cipher     = var.cato_authMessage_cipher
    auth_integrity  = var.cato_authMessage_integrity
})}
PAYLOAD
EOT
}
}

resource "terraform_data" "update_ipsec_site_details-nobgp" {
  #Null Resource has been replaced by "terraform_data"
  depends_on = [cato_ipsec_site.ipsec-site]
  count      = var.enable_bgp ? 0 : 1

  triggers_replace = [
    cato_ipsec_site.ipsec-site.id,
    var.cato_authMessage_integrity,
    var.cato_authMessage_cipher,
    var.cato_authMessage_dhGroup,
    var.cato_initMessage_prf,
    var.cato_initMessage_integrity,
    var.cato_initMessage_cipher,
    var.cato_initMessage_dhGroup,
    var.cato_connectionMode,
    var.peer_networks
  ]

  provisioner "local-exec" {
    # This command uses a 'heredoc' to pipe the rendered JSON template
    # directly into curl's standard input.
    # The '--data @-' argument tells curl to read the POST data from stdin.
    # For Debugging the API Call, add '-v' to the curl statement before the '-k'
    command = <<EOT
cat <<'PAYLOAD' | curl -k -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' -H 'x-API-Key: ${var.token}' '${var.baseurl}' --data @-
${templatefile("${path.module}/templates/update_site_payload_nobgp.json.tftpl", {
    account_id          = var.account_id
    site_id             = cato_ipsec_site.ipsec-site.id
    connection_mode     = var.cato_connectionMode
    network_ranges_json = jsonencode(var.peer_networks) #jsonencode converts the Terraform list to a JSON array string
    init_dh_group       = var.cato_initMessage_dhGroup
    init_cipher         = var.cato_initMessage_cipher
    init_integrity      = var.cato_initMessage_integrity
    init_prf            = var.cato_initMessage_prf
    auth_dh_group       = var.cato_authMessage_dhGroup
    auth_cipher         = var.cato_authMessage_cipher
    auth_integrity      = var.cato_authMessage_integrity
})}
PAYLOAD
EOT
}
}

# If BGP Enabled, build the BGP Configuration on the Cato Side.
resource "cato_bgp_peer" "primary" {
  count                    = var.enable_bgp ? 1 : 0
  site_id                  = cato_ipsec_site.ipsec-site.id
  name                     = var.cato_primary_bgp_peer_name == null ? "${var.site_name}-primary-bgp-peer" : var.cato_primary_bgp_peer_name
  cato_asn                 = var.cato_bgp_asn
  peer_asn                 = var.peer_bgp_asn
  peer_ip                  = var.primary_private_site_ip
  metric                   = var.cato_primary_bgp_metric
  default_action           = var.cato_primary_bgp_default_action
  advertise_all_routes     = var.cato_primary_bgp_advertise_all
  advertise_default_route  = var.cato_primary_bgp_advertise_default_route
  advertise_summary_routes = var.cato_primary_bgp_advertise_summary_route
  md5_auth_key             = "" #Inserting Blank Value to Avoid State Changes 

  bfd_settings = {
    transmit_interval = var.cato_primary_bgp_bfd_transmit_interval
    receive_interval  = var.cato_primary_bgp_bfd_receive_interval
    multiplier        = var.cato_primary_bgp_bfd_multiplier
  }
  # Inserting Ignore to avoid API and TF Fighting over a Null Value 
  lifecycle {
    ignore_changes = [
      summary_route
    ]
  }
}

resource "cato_bgp_peer" "backup" {
  count                    = var.enable_bgp && var.ha_tunnels ? 1 : 0
  site_id                  = cato_ipsec_site.ipsec-site.id
  name                     = var.cato_secondary_bgp_peer_name == null ? "${var.site_name}-secondary-bgp-peer" : var.cato_secondary_bgp_peer_name
  cato_asn                 = var.cato_bgp_asn
  peer_asn                 = var.peer_bgp_asn
  peer_ip                  = var.secondary_private_site_ip
  metric                   = var.cato_secondary_bgp_metric
  default_action           = var.cato_secondary_bgp_default_action
  advertise_all_routes     = var.cato_secondary_bgp_advertise_all
  advertise_default_route  = var.cato_secondary_bgp_advertise_default_route
  advertise_summary_routes = var.cato_secondary_bgp_advertise_summary_route
  md5_auth_key             = "" #Inserting Blank Value to Avoid State Changes 

  bfd_settings = {
    transmit_interval = var.cato_secondary_bgp_bfd_transmit_interval
    receive_interval  = var.cato_secondary_bgp_bfd_receive_interval
    multiplier        = var.cato_secondary_bgp_bfd_multiplier
  }

  lifecycle {
    ignore_changes = [
      summary_route
    ]
  }
}

resource "cato_license" "license" {
  depends_on = [cato_ipsec_site.ipsec-site]
  count      = var.license_id == null ? 0 : 1
  site_id    = cato_ipsec_site.ipsec-site.id
  license_id = var.license_id
  bw         = var.license_bw == null ? null : var.license_bw
}
