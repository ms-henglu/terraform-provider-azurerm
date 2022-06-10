
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-220610022206619556"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf220610022206619556"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
