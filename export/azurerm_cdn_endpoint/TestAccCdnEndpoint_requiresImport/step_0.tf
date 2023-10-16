
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033515732672"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof231016033515732672"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend231016033515732672"
  profile_name        = azurerm_cdn_profile.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  origin {
    name       = "acceptanceTestCdnOrigin1"
    host_name  = "www.contoso.com"
    https_port = 443
    http_port  = 80
  }
}
