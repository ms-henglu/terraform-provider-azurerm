

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119021426642382"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-240119021426642382"
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

resource "azurerm_api_management_group" "test" {
  name                = "acctestAMGroup-240119021426642382"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "Test Group"
}

resource "azurerm_api_management_product_group" "test" {
  product_id          = azurerm_api_management_product.test.product_id
  group_name          = azurerm_api_management_group.test.name
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_api_management_product_group" "import" {
  product_id          = azurerm_api_management_product_group.test.product_id
  group_name          = azurerm_api_management_product_group.test.group_name
  api_management_name = azurerm_api_management_product_group.test.api_management_name
  resource_group_name = azurerm_api_management_product_group.test.resource_group_name
}
