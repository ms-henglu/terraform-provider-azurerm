
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230929064510070335"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof230929064510070335"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend230929064510070335"
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
      behavior = "Override"
      duration = "5.04:44:23"
    }
    cache_key_query_string_action {
      behavior   = "IncludeAll"
      parameters = "test"
    }
    modify_request_header_action {
      action = "Append"
      name   = "www.contoso1.com"
      value  = "test value"
    }
    url_redirect_action {
      redirect_type = "Found"
      protocol      = "Https"
      hostname      = "www.contoso.com"
      fragment      = "5fgdfg"
      path          = "/article.aspx"
      query_string  = "id={var_uri_path_1}&title={var_uri_path_2}"
    }
  }
}
