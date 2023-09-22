

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230922053516782886"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-230922053516782886"
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
  subscription_required = false
  published             = false
}

resource "azurerm_api_management_product_policy" "test" {
  product_id          = azurerm_api_management_product.test.product_id
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  xml_link            = "https://gist.githubusercontent.com/riordanp/ca22f8113afae0eb38cc12d718fd048d/raw/d6ac89a2f35a6881a7729f8cb4883179dc88eea1/example.xml"
}


resource "azurerm_api_management_product_policy" "import" {
  product_id          = azurerm_api_management_product_policy.test.product_id
  api_management_name = azurerm_api_management_product_policy.test.api_management_name
  resource_group_name = azurerm_api_management_product_policy.test.resource_group_name
  xml_link            = azurerm_api_management_product_policy.test.xml_link
}
