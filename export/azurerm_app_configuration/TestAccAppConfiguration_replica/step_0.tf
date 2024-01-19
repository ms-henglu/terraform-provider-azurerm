
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-240119024414832406"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf240119024414832406"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"

  replica {
    name     = "replica1"
    location = "East US 2"
  }
}
