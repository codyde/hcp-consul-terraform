provider "consul" {
  address    = var.cluster
  datacenter = var.consuldc
  token      = var.token
}


