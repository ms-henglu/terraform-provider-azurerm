
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-231218071141876919"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf231218071141876919"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
