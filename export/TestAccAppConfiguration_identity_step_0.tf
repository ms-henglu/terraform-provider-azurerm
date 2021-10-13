
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211013071507554417"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf211013071507554417"
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
