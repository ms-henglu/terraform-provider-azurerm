
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appconfig-230707003241251264"
  location = "West Europe"
}

resource "azurerm_app_configuration" "test" {
  name                = "testaccappconf230707003241251264"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "standard"
}
