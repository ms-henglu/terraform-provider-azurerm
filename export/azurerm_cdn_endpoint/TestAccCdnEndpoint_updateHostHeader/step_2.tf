
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230227175154983314"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof230227175154983314"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "test" {
  name                = "acctestcdnend230227175154983314"
  profile_name        = azurerm_cdn_profile.test.name
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  origin_host_header  = "www.example2.com"

  origin {
    name       = "acceptanceTestCdnOrigin2"
    host_name  = "www.contoso.com"
    https_port = 443
    http_port  = 80
  }

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
