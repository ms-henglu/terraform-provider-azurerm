


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231020041342982614"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-231020041342982614"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_trigger_http_request" "test" {
  name         = "some-http-trigger"
  logic_app_id = azurerm_logic_app_workflow.test.id
  schema       = "{}"
}


resource "azurerm_logic_app_trigger_http_request" "import" {
  name         = azurerm_logic_app_trigger_http_request.test.name
  logic_app_id = azurerm_logic_app_trigger_http_request.test.logic_app_id
  schema       = azurerm_logic_app_trigger_http_request.test.schema
}
