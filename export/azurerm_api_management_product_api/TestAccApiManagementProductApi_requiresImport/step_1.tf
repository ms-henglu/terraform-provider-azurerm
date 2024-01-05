

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240105060149968733"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240105060149968733"
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
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-240105060149968733"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "api1"
  path                = "api1"
  protocols           = ["https"]
  revision            = "1"
}

resource "azurerm_api_management_product_api" "test" {
  product_id          = azurerm_api_management_product.test.product_id
  api_name            = azurerm_api_management_api.test.name
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_api_management_product_api" "import" {
  api_name            = azurerm_api_management_product_api.test.api_name
  product_id          = azurerm_api_management_product_api.test.product_id
  api_management_name = azurerm_api_management_product_api.test.api_management_name
  resource_group_name = azurerm_api_management_product_api.test.resource_group_name
}
