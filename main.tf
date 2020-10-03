provider "consul" {
  address    = var.cluster
  datacenter = var.consuldc
  token      = var.token
}

resource "consul_service" "hcpgsql" {
  name    = "hcpgsql"
  node    = "${consul_node.hcpgsql.name}"
  port    = 5432
  tags    = ["external"]
}

resource "consul_node" "hcpgsql" {
  name    = "hcpgsql"
  address = "postgres.cbjb8qnvkuc9.us-west-2.rds.amazonaws.com"
  meta = {
    "external-node" = "true"
    "external-probe" = "true"
    }
}

resource "consul_intention" "fe-igw-allow" {
    source_name      = "ingress-gateway"
    destination_name = "frontend"
    action           = "allow"
  }

resource "consul_intention" "fe-api-allow" {
      source_name      = "frontend"
      destination_name = "api"
      action           = "allow"
    }

resource "consul_intention" "api-db-allow" {
        source_name      = "api"
        destination_name = "db"
        action           = "allow"
      }

resource "consul_config_entry" "frontend" {
  name = "frontend"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol    = "http"
  })
}

resource "consul_config_entry" "ingress_gateway" {
    name = "ingress-gateway"
    kind = "ingress-gateway"

    config_json = jsonencode({
        TLS = {
            Enabled = true
        }
        Listeners = [{
            Port     = 8080
            Protocol = "http"
            Services = [
              { 
                Name  = "frontend"
                Hosts = [*] 
                }
              ]
        }]
    })
}

resource "consul_config_entry" "terminating_gateway" {
    name = "terminating-gateway"
    kind = "terminating-gateway"

    config_json = jsonencode({
        Services = [{ Name = "hcpgsql" }]
    })
  }
