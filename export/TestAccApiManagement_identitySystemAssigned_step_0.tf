
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220114013835500403"
  location = "West Europe"
}
resource "azurerm_api_management" "test" {
  name                = "acctestAM-220114013835500403"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Developer_1"
  identity {
    type = "SystemAssigned"
  }
}
