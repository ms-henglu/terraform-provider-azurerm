
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421021756292228"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof230421021756292228"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "test" {
  name                          = "acctestcdnend230421021756292228"
  profile_name                  = azurerm_cdn_profile.test.name
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  is_http_allowed               = true
  is_https_allowed              = true
  content_types_to_compress     = ["text/html"]
  is_compression_enabled        = true
  querystring_caching_behaviour = "UseQueryString"
  origin_host_header            = "www.contoso.com"
  optimization_type             = "GeneralWebDelivery"
  origin_path                   = "/origin-path"
  probe_path                    = "/origin-path/probe"

  origin {
    name       = "acceptanceTestCdnOrigin1"
    host_name  = "www.contoso.com"
    https_port = 443
    http_port  = 80
  }

  geo_filter {
    relative_path = "/some-example-endpoint"
    action        = "Allow"
    country_codes = ["GB"]
  }

  tags = {
    environment = "Production"
  }
}
