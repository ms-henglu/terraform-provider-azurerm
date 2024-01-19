

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025300898747"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-240119025300898747"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "test" {
  name         = "action240119025300898747"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "GET"
  uri          = "http://example.com/hello"

  headers = {
    "Hello"     = "World"
    "Something" = "New"
  }
}
