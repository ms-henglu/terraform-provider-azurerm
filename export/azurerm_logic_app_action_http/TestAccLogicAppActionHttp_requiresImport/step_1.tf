


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024815943701"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230825024815943701"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "test" {
  name         = "action230825024815943701"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "GET"
  uri          = "http://example.com/hello"
}


resource "azurerm_logic_app_action_http" "import" {
  name         = azurerm_logic_app_action_http.test.name
  logic_app_id = azurerm_logic_app_action_http.test.logic_app_id
  method       = azurerm_logic_app_action_http.test.method
  uri          = azurerm_logic_app_action_http.test.uri
}
