


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230810143727865825"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230810143727865825"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "test" {
  name         = "action230810143727865825"
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
