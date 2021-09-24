

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924011143871490"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-210924011143871490"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "testp1" {
  name         = "action210924011143871490p1"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "GET"
  uri          = "http://example.com/hello"
}

resource "azurerm_logic_app_action_http" "testp2" {
  name         = "action210924011143871490p2"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "GET"
  uri          = "http://example.com/hello"
}

resource "azurerm_logic_app_action_http" "test" {
  name         = "action210924011143871490"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "GET"
  uri          = "http://example.com/hello"
  run_after {
    action_name   = azurerm_logic_app_action_http.testp1.name
    action_result = "Failed"
  }
  run_after {
    action_name   = azurerm_logic_app_action_http.testp2.name
    action_result = "Failed"
  }
}
