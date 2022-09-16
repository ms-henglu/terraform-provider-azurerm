
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220916011152217396"
  location = "West Europe"
}

resource "azurerm_cdn_profile" "test" {
  name                = "acctestcdnprof220916011152217396"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Standard_Akamai"
}
