provider "consul" {
  address    = var.cluster
  datacenter = var.consuldc
  token      = var.token
}

resource "consul_intention" "fe-igw-allow" {
    source_name      = "ingress-gateway"
    destination_name = "frontend"
    action           = "allow"
  }
