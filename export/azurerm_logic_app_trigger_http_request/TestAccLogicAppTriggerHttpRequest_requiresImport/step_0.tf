

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230113181321213338"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230113181321213338"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_trigger_http_request" "test" {
  name         = "some-http-trigger"
  logic_app_id = azurerm_logic_app_workflow.test.id
  schema       = "{}"
}
