
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024619119404"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof240119024619119404"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend240119024619119404"
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
}
