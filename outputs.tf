output "ipsec_site_id" {
  description = "The ID of the created Cato IPsec site."
  value       = cato_ipsec_site.ipsec-site.id
}

output "primary_tunnel_psk" {
  description = "The pre-shared key for the primary IPsec tunnel. This is sensitive and will be the generated key if not provided as an input."
  value       = cato_ipsec_site.ipsec-site.ipsec.primary.tunnels[0].psk
  sensitive   = true
}

output "secondary_tunnel_psk" {
  description = "The pre-shared key for the secondary IPsec tunnel if HA is enabled. This is sensitive and will be the generated key if not provided as an input."
  value       = var.ha_tunnels ? cato_ipsec_site.ipsec-site.ipsec.secondary.tunnels[0].psk : null
  sensitive   = true
}

output "cato_primary_public_ip" {
  description = "The Cato public IP address for the primary tunnel."
  value       = var.primary_cato_pop_ip != null ? data.cato_allocatedIp.primary[0].items[0].name : "Not configured"
}

output "cato_secondary_public_ip" {
  description = "The Cato public IP address for the secondary tunnel (if HA is enabled)."
  value       = var.ha_tunnels && var.secondary_cato_pop_ip != null ? data.cato_allocatedIp.secondary[0].items[0].name : "Not configured or HA not enabled"
}

output "primary_bgp_peer_id" {
  description = "The ID of the primary BGP peer, if BGP is enabled."
  value       = var.enable_bgp ? cato_bgp_peer.primary[0].id : null
}

output "secondary_bgp_peer_id" {
  description = "The ID of the secondary BGP peer, if BGP and HA are enabled."
  value       = var.enable_bgp && var.ha_tunnels ? cato_bgp_peer.backup[0].id : null
}

output "ipsec_site_configuration_details" {
  description = "Detailed configuration of the IPsec site."
  value       = cato_ipsec_site.ipsec-site
  sensitive   = true # Contains PSKs
}

output "random_primary_shared_key_result" {
  description = "The randomly generated primary shared key. Only populated if a primary_connection_shared_key was not provided."
  value       = random_password.shared_key_primary.result
  sensitive   = true
}

output "random_secondary_shared_key_result" {
  description = "The randomly generated secondary shared key. Only populated if a secondary_connection_shared_key was not provided and HA tunnels are enabled."
  value       = var.ha_tunnels ? random_password.shared_key_secondary.result : null
  sensitive   = true
}

output "license_assignment_id" {
  description = "The ID of the license assignment, if a license was assigned."
  value       = var.license_id != null ? cato_license.license[0].id : "No license assigned"
}