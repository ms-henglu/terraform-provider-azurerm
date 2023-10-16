

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-frontdoor-231016033950792515"
  location = "West Europe"
}

locals {
  backend_name        = "backend-bing-custom"
  endpoint_name       = "frontend-endpoint-custom"
  health_probe_name   = "health-probe-custom"
  load_balancing_name = "load-balancing-setting-custom"
}

resource "azurerm_frontdoor" "test" {
  name                = "acctest-FD-231016033950792515"
  resource_group_name = azurerm_resource_group.test.name

  backend_pool_settings {
    enforce_backend_pools_certificate_name_check = false
  }

  routing_rule {
    name               = "routing-rule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.endpoint_name]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = local.backend_name
    }
  }

  backend_pool_load_balancing {
    name = local.load_balancing_name
  }

  backend_pool_health_probe {
    name = local.health_probe_name
  }

  backend_pool {
    name = local.backend_name
    backend {
      host_header = "www.bing.com"
      address     = "www.bing.com"
      http_port   = 80
      https_port  = 443
    }

    load_balancing_name = local.load_balancing_name
    health_probe_name   = local.health_probe_name
  }

  frontend_endpoint {
    name      = local.endpoint_name
    host_name = "acctest-FD-231016033950792515.azurefd.net"
  }
}


resource "azurerm_frontdoor_custom_https_configuration" "test" {
  frontend_endpoint_id              = azurerm_frontdoor.test.frontend_endpoints[local.endpoint_name]
  custom_https_provisioning_enabled = true

  custom_https_configuration {
    certificate_source = "FrontDoor"
  }
}
