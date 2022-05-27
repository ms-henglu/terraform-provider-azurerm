
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-220527033807055644"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf220527033807055644"
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
