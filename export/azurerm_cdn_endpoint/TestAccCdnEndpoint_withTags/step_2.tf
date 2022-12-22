
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034326959302"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof221222034326959302"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend221222034326959302"
  profile_name        = azurerm_cdn_profile.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  origin {
    name       = "acceptanceTestCdnOrigin2"
    host_name  = "www.contoso.com"
    https_port = 443
    http_port  = 80
  }

  tags = {
    environment = "staging"
  }
}
