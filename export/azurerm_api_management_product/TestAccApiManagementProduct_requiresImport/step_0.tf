
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033300940108"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231016033300940108"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Consumption_0"
}

resource "azurerm_api_management_product" "test" {
  product_id            = "test-product"
  api_management_name   = azurerm_api_management.test.name
  resource_group_name   = azurerm_resource_group.test.name
  display_name          = "Test Product"
  subscription_required = false
  published             = false
}
