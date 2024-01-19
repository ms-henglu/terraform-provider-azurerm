

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119024407458813"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240119024407458813"
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

resource "azurerm_api_management_tag" "test" {
  api_management_id = azurerm_api_management.test.id
  name              = "acctestTag-240119024407458813"
}

resource "azurerm_api_management_product_tag" "test" {
  api_management_product_id = azurerm_api_management_product.test.product_id
  api_management_name       = azurerm_api_management.test.name
  resource_group_name       = azurerm_resource_group.test.name
  name                      = azurerm_api_management_tag.test.name
}


resource "azurerm_api_management_product_tag" "import" {
  api_management_product_id = azurerm_api_management_product_tag.test.api_management_product_id
  api_management_name       = azurerm_api_management_product_tag.test.api_management_name
  resource_group_name       = azurerm_api_management_product_tag.test.resource_group_name
  name                      = azurerm_api_management_product_tag.test.name
}
