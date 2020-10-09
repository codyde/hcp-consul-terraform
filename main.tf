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

resource "consul_config_entry" "frontend" {
  name = "frontend"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol    = "http"
  })
  }

resource "consul_config_entry" "ingress" {
    depends_on = [consul_config_entry.frontend]
    kind = "ingress-gateway"
    name = "ingress-gateway"

    config_json = jsonencode({
        Listeners = [{
          Port = 80
          Protocol = "http"
          Services = [{
            Name = "frontend"
            Hosts = ["*"]
          }]}
        ]
    })
  }


