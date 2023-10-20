
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-frontdoor-231020041127855650"
  location = "West Europe"
}

locals {
  backend_name        = "backend-bing"
  endpoint_name       = "frontend-endpoint"
  health_probe_name   = "health-probe"
  load_balancing_name = "load-balancing-setting"
}

resource "azurerm_frontdoor" "test" {
  name                  = "acctest-FD-231020041127855650"
  resource_group_name   = azurerm_resource_group.test.name
  friendly_name         = "TestGroup"
  load_balancer_enabled = false

  backend_pool_settings {
    enforce_backend_pools_certificate_name_check = false
    backend_pools_send_receive_timeout_seconds   = 45
  }


  routing_rule {
    name               = "routing-rule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = [local.endpoint_name]
    enabled            = false
    forwarding_configuration {
      forwarding_protocol    = "MatchRequest"
      backend_pool_name      = local.backend_name
      custom_forwarding_path = "/"
    }
  }

  backend_pool_load_balancing {
    name = local.load_balancing_name
  }

  backend_pool_health_probe {
    name                = local.health_probe_name
    interval_in_seconds = 30
    path                = "/"
  }

  backend_pool {
    name = local.backend_name
    backend {
      host_header = "www.bing.com"
      address     = "www.bing.com"
      http_port   = 80
      https_port  = 443
      priority    = 2
    }

    load_balancing_name = local.load_balancing_name
    health_probe_name   = local.health_probe_name
  }

  frontend_endpoint {
    name                         = local.endpoint_name
    host_name                    = "acctest-FD-231020041127855650.azurefd.net"
    session_affinity_enabled     = true
    session_affinity_ttl_seconds = 2
  }
  tags = {
    ENV = "Test"
  }
}
