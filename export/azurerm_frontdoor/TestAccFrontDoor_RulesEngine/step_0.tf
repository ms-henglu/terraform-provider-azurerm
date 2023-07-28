
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-frontdoor-230728032332971276"
  location = "West Europe"
}

resource "azurerm_frontdoor" "test" {
  name                = "acctest-FD-230728032332971276"
  resource_group_name = azurerm_resource_group.test.name

  backend_pool_settings {
    enforce_backend_pools_certificate_name_check = false
  }

  frontend_endpoint {
    name      = "acctest-FD-230728032332971276-default-FE"
    host_name = "acctest-FD-230728032332971276.azurefd.net"
  }

  routing_rule {
    name               = "acctest-FD-230728032332971276-bing-RR"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/poolBing/*"]
    frontend_endpoints = ["acctest-FD-230728032332971276-default-FE"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "acctest-FD-230728032332971276-pool-bing"
      cache_enabled       = false
    }
  }

  backend_pool_load_balancing {
    name                            = "acctest-FD-230728032332971276-bing-LB"
    additional_latency_milliseconds = 0
    sample_size                     = 4
    successful_samples_required     = 2
  }

  backend_pool_health_probe {
    name         = "acctest-FD-230728032332971276-bing-HP"
    protocol     = "Https"
    enabled      = true
    probe_method = "HEAD"
  }

  backend_pool {
    name                = "acctest-FD-230728032332971276-pool-bing"
    load_balancing_name = "acctest-FD-230728032332971276-bing-LB"
    health_probe_name   = "acctest-FD-230728032332971276-bing-HP"

    backend {
      host_header = "bing.com"
      address     = "bing.com"
      http_port   = 80
      https_port  = 443
      weight      = 75
      enabled     = true
    }
  }
}

resource "azurerm_frontdoor_rules_engine" "sample_engine_config" {
  name                = "CORSAPI"
  frontdoor_name      = azurerm_frontdoor.test.name
  resource_group_name = azurerm_resource_group.test.name

  rule {
    name     = "debug"
    priority = 1

    match_condition {
      variable = "RequestMethod"
      operator = "Equal"
      value    = ["GET", "POST"]
    }

    action {
      response_header {
        header_action_type = "Append"
        header_name        = "X-TEST-HEADER"
        value              = "CORS API Rule"
      }
    }
  }

  rule {
    name     = "origin"
    priority = 2

    action {
      request_header {
        header_action_type = "Overwrite"
        header_name        = "Origin"
        value              = "*"
      }
      response_header {
        header_action_type = "Overwrite"
        header_name        = "Access-Control-Allow-Origin"
        value              = "*"
      }
      response_header {
        header_action_type = "Overwrite"
        header_name        = "Access-Control-Allow-Credentials"
        value              = "true"
      }
    }
  }

  depends_on = [
    azurerm_frontdoor.test
  ]
}
