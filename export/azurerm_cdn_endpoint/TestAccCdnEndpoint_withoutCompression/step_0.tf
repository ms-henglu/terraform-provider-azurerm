
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804025538085338"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof230804025538085338"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend230804025538085338"
  profile_name        = azurerm_cdn_profile.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  is_http_allowed     = false
  is_https_allowed    = true
  optimization_type   = "GeneralWebDelivery"

  origin {
    name       = "acceptanceTestCdnOrigin1"
    host_name  = "www.contoso.com"
    https_port = 443
    http_port  = 80
  }
}
