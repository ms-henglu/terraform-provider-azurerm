

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240311031231526456"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240311031231526456"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"

  sku_name = "Developer_1"
}

resource "azurerm_api_management_product" "test" {
  product_id            = "test-product"
  api_management_name   = azurerm_api_management.test.name
  resource_group_name   = azurerm_resource_group.test.name
  display_name          = "Test Product"
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_user" "test" {
  user_id             = "acctestuser240311031231526456"
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  first_name          = "Acceptance"
  last_name           = "Test"
  email               = "azure-acctest240311031231526456@example.com"
}


resource "azurerm_api_management_subscription" "test" {
  resource_group_name = azurerm_api_management.test.resource_group_name
  api_management_name = azurerm_api_management.test.name
  user_id             = azurerm_api_management_user.test.id
  product_id          = azurerm_api_management_product.test.id
  display_name        = "Butter Parser API Enterprise Edition"
  state               = "suspended"
  allow_tracing       = true
}
