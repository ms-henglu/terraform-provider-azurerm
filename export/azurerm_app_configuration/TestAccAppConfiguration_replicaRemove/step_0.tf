
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-231016033308381841"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf231016033308381841"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  replica {
    name     = "replica1"
    location = "East US 2"
  }
}
