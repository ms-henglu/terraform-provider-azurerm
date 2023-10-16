


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033300915694"
  location = "West Europe"
}

resource "azurerm_api_management" "test" {
  name                = "acctestAM-231016033300915694"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  publisher_name      = "pub1"
  publisher_email     = "pub1@email.com"
  sku_name            = "Consumption_0"
}

resource "azurerm_api_management_api" "test" {
  name                = "acctestapi-231016033300915694"
  resource_group_name = azurerm_resource_group.test.name
  api_management_name = azurerm_api_management.test.name
  display_name        = "Butter Parser"
  path                = "butter-parser"
  protocols           = ["https", "http"]
  revision            = "3"
  description         = "What is my purpose? You parse butter."
  service_url         = "https://example.com/foo/bar"

  subscription_key_parameter_names {
    header = "X-Butter-Robot-API-Key"
    query  = "location"
  }
}


resource "azurerm_api_management_api_operation" "test" {
  operation_id        = "acctest-operation"
  api_name            = azurerm_api_management_api.test.name
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  display_name        = "DELETE Resource"
  method              = "DELETE"
  url_template        = "/resource"
}


resource "azurerm_api_management_api_operation_policy" "test" {
  api_name            = azurerm_api_management_api.test.name
  api_management_name = azurerm_api_management.test.name
  resource_group_name = azurerm_resource_group.test.name
  operation_id        = azurerm_api_management_api_operation.test.operation_id
  xml_link            = "https://gist.githubusercontent.com/riordanp/ca22f8113afae0eb38cc12d718fd048d/raw/d6ac89a2f35a6881a7729f8cb4883179dc88eea1/example.xml"
}
