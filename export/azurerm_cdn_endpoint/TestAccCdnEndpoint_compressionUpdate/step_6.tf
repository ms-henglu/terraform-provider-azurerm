
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231013043043794844"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof231013043043794844"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Verizon"
}

resource "azurerm_cdn_endpoint" "test" {
  name                      = "acctestcdnend231013043043794844"
  profile_name              = azurerm_cdn_profile.test.name
  location                  = azurerm_resource_group.test.location
  resource_group_name       = azurerm_resource_group.test.name
  is_http_allowed           = true
  is_https_allowed          = true
  content_types_to_compress = ["text/html"]
  is_compression_enabled    = true

  origin {
    name      = "acceptanceTestCdnOrigin1"
    host_name = "www.contoso.com"
  }

  tags = {
    environment = "production"
  }
}
