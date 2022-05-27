
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-frontdoor-220527024239378803"
  location = "West Europe"
}

resource "azurerm_frontdoor" "test" {
  name                = "acctest-FD-220527024239378803"
  resource_group_name = azurerm_resource_group.test.name

  backend_pool_settings {
    enforce_backend_pools_certificate_name_check = false
  }

  frontend_endpoint {
    name      = "acctest-FD-220527024239378803-default-FE"
    host_name = "acctest-FD-220527024239378803.azurefd.net"
  }

  # --- Pool 1

  routing_rule {
    name               = "acctest-FD-220527024239378803-bing-RR"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/poolBing/*"]
    frontend_endpoints = ["acctest-FD-220527024239378803-default-FE"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "acctest-FD-220527024239378803-pool-bing"
      cache_enabled       = true
    }
  }

  backend_pool_load_balancing {
    name                            = "acctest-FD-220527024239378803-bing-LB"
    additional_latency_milliseconds = 0
    sample_size                     = 4
    successful_samples_required     = 2
  }

  backend_pool_health_probe {
    name         = "acctest-FD-220527024239378803-bing-HP"
    protocol     = "Https"
    enabled      = true
    probe_method = "HEAD"
  }

  backend_pool {
    name                = "acctest-FD-220527024239378803-pool-bing"
    load_balancing_name = "acctest-FD-220527024239378803-bing-LB"
    health_probe_name   = "acctest-FD-220527024239378803-bing-HP"

    backend {
      host_header = "bing.com"
      address     = "bing.com"
      http_port   = 80
      https_port  = 443
      weight      = 75
      enabled     = true
    }
  }

  # --- Pool 2

  routing_rule {
    name               = "acctest-FD-220527024239378803-google-RR"
    accepted_protocols = ["Https"]
    patterns_to_match  = ["/poolGoogle/*"]
    frontend_endpoints = ["acctest-FD-220527024239378803-default-FE"]

    forwarding_configuration {
      forwarding_protocol = "MatchRequest"
      backend_pool_name   = "acctest-FD-220527024239378803-pool-google"
      cache_enabled       = true
    }
  }

  backend_pool_load_balancing {
    name                            = "acctest-FD-220527024239378803-google-LB"
    additional_latency_milliseconds = 0
    sample_size                     = 4
    successful_samples_required     = 2
  }

  backend_pool_health_probe {
    name     = "acctest-FD-220527024239378803-google-HP"
    protocol = "Https"
  }

  backend_pool {
    name                = "acctest-FD-220527024239378803-pool-google"
    load_balancing_name = "acctest-FD-220527024239378803-google-LB"
    health_probe_name   = "acctest-FD-220527024239378803-google-HP"

    backend {
      host_header = "google.com"
      address     = "google.com"
      http_port   = 80
      https_port  = 443
      weight      = 75
      enabled     = true
    }
  }
}
