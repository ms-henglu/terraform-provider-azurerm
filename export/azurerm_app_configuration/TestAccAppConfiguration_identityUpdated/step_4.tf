
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-221021033747301128"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf221021033747301128"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
