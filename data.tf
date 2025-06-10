data "cato_allocatedIp" "primary" {
  count       = var.primary_cato_pop_ip == null ? 0 : 1
  name_filter = [var.primary_cato_pop_ip]
}

data "cato_allocatedIp" "secondary" {
  count       = var.secondary_cato_pop_ip == null ? 0 : 1
  name_filter = [var.secondary_cato_pop_ip]
}