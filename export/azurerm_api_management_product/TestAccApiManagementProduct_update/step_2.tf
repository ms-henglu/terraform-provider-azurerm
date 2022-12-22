
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221222034202309940"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-221222034202309940"
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
  display_name          = "Test Updated Product"
  subscription_required = true
  approval_required     = true
  subscriptions_limit   = 1
  published             = true
}
