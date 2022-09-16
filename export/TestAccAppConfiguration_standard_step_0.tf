
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-220916011048504485"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                  = "testaccappconf220916011048504485"
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  public_network_access = "Disabled"
  sku                   = "standard"
}
