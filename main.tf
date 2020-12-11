provider "consul" {
  address    = var.cluster
  datacenter = var.consuldc
  token      = var.token
}

// resource "consul_config_entry" "api_resolver" {
//   kind = "service-resolver"
//   name = consul_config_entry.api.name

//   config_json = jsonencode({
//     DefaultSubset = "v2"

//     Subsets = {
//       "v1" = {
//         Filter = "Service.Meta.version == v1"
//       }
//       "v2" = {
//         Filter = "Service.Meta.version == v2"
//       }
//     }
//   })
// }

// resource "consul_config_entry" "api_splitter" {
//   kind = "service-splitter"
//   name = consul_config_entry.api_resolver.name

//   config_json = jsonencode({
//     Splits = [
//       {
//         Weight        = 0
//         ServiceSubset = "v1"
//       },
//       {
//         Weight        = 100
//         ServiceSubset = "v2"
//       },
//     ]
//   })
// } 

// resource "consul_config_entry" "frontend_resolver" {
//   kind = "service-resolver"
//   name = consul_config_entry.frontend.name

//   config_json = jsonencode({
//     DefaultSubset = "v2"

//     Subsets = {
//       "v1" = {
//         Filter = "Service.Meta.version == v1"
//       }
//       "v2" = {
//         Filter = "Service.Meta.version == v2"
//       }
//     }
//   })
// }

// resource "consul_config_entry" "frontend_splitter" {
//   kind = "service-splitter"
//   name = consul_config_entry.frontend_resolver.name

//   config_json = jsonencode({
//     Splits = [
//       {
//         Weight        = 0
//         ServiceSubset = "v1"
//       },
//       {
//         Weight        = 100
//         ServiceSubset = "v2"
//       },
//     ]
//   })
// }


resource "consul_service" "db" {
  name    = "db"
  node    = consul_node.awsrdspg.name
  port    = 5432
  tags    = ["external"]
}

resource "consul_node" "awsrdspg" {
  name    = "awsrdspg"
  address = "172.31.36.61"
  meta = {
    "external-node" = "true"
    "external-probe" = "true"
    }
}

resource "consul_intention" "api-db-allow" {
        source_name      = "api"
        destination_name = "db"
        action           = "allow"
      }

resource "consul_config_entry" "terminating_gateway" {
    name = "terminating-gateway"
    kind = "terminating-gateway"

    config_json = jsonencode({
        Services = [{ Name = "db" }]
    })
  }

// resource "consul_config_entry" "api" {
//   name = "api"
//   kind = "service-defaults"

//   config_json = jsonencode({
//     Protocol    = "http"
//   })
//   }

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
