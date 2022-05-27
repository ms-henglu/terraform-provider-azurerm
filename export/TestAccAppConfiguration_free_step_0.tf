
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-220527033807051746"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testacc-appconf220527033807051746"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "free"
}
