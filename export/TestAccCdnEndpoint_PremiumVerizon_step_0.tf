
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217074957493779"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof211217074957493779"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Premium_Verizon"
}

resource "azurerm_cdn_endpoint" "test" {
  name                          = "acctestcdnend211217074957493779"
  profile_name                  = azurerm_cdn_profile.test.name
  location                      = azurerm_resource_group.test.location
  resource_group_name           = azurerm_resource_group.test.name
  is_http_allowed               = false
  is_https_allowed              = true
  querystring_caching_behaviour = "NotSet"

  origin {
    name       = "acceptanceTestCdnOrigin1"
    host_name  = "www.contoso.com"
    https_port = 443
    http_port  = 80
  }
}
