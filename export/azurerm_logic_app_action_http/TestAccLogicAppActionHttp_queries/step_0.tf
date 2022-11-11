

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221111013805655686"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-221111013805655686"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "test" {
  name         = "action221111013805655686"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "GET"
  uri          = "http://example.com/hello"

  queries = {
    "Hello"     = "World"
    "Something" = "New"
  }
}
