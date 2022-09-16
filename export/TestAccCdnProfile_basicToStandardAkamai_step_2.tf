
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011152218643"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof220916011152218643"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Akamai"
}
