

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014429869567"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-211015014429869567"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "test" {
  name         = "action211015014429869567"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "GET"
  uri          = "http://example.com/hello"
}
