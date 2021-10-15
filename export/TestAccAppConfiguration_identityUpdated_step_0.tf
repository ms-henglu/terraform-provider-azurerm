
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-211015014307513338"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf211015014307513338"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
