
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230316220957052547"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230316220957052547"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_product" "test" {
  product_id            = "test-product"
  api_management_name   = azurerm_api_management.test.name
  resource_group_name   = azurerm_resource_group.test.name
  display_name          = "Test Product"
  approval_required     = true
  subscription_required = false
  published             = true
  description           = "This is an example description"
  terms                 = "These are some example terms and conditions"
}
