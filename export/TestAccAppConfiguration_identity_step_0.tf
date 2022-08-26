
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-220826002320015980"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf220826002320015980"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    ENVironment = "DEVelopment"
  }
}
