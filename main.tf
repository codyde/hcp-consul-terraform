provider "consul" {
  address    = var.cluster
  datacenter = var.consuldc
  token      = var.token
}

resource "consul_acl_policy" "hcpgsql-policy" {
  name        = "hcpgsql-policy"
  rules       = <<-RULE
    node_prefix "hcpgsql" {
      policy = "write"
    }
    RULE
}
