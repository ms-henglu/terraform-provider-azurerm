

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825023946791356"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230825023946791356"
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


resource "azurerm_api_management_product" "import" {
  product_id            = azurerm_api_management_product.test.product_id
  api_management_name   = azurerm_api_management_product.test.api_management_name
  resource_group_name   = azurerm_api_management_product.test.resource_group_name
  display_name          = azurerm_api_management_product.test.display_name
  subscription_required = azurerm_api_management_product.test.subscription_required
  approval_required     = azurerm_api_management_product.test.approval_required
  published             = azurerm_api_management_product.test.published
}
