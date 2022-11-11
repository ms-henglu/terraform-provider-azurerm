
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-221111013038040780"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf221111013038040780"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
