
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230915023019307631"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof230915023019307631"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend230915023019307631"
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

  delivery_rule {
    name  = "http2https"
    order = 1

    request_scheme_condition {
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
    }
    cache_expiration_action {
      behavior = "Override"
      duration = "5.04:44:23"
    }
    cache_key_query_string_action {
      behavior   = "IncludeAll"
      parameters = "test"
    }
    cookies_condition {
      operator         = "Contains"
      selector         = "abc"
      negate_condition = false
      match_values     = ["windows"]
      transforms       = ["Lowercase"]

    }
  }
}
