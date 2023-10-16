
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033515734286"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof231016033515734286"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend231016033515734286"
  profile_name        = azurerm_cdn_profile.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  origin_host_header = "www.contoso.com"

  origin {
    name       = "acceptanceTestCdnOrigin1"
    host_name  = "www.contoso.com"
    https_port = 443
    http_port  = 80
  }

  global_delivery_rule {
    cache_expiration_action {
      behavior = "SetIfMissing"
      duration = "12.04:11:22"
    }

    modify_response_header_action {
      action = "Overwrite"
      name   = "Content-Type"
      value  = "application/json"
    }
    url_rewrite_action {
      source_pattern          = "/test_source_pattern"
      destination             = "/test_destination"
      preserve_unmatched_path = false
    }
  }
}
