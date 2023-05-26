

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230526085351893230"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230526085351893230"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "test" {
  name         = "action230526085351893230"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "POST"
  uri          = "http://example.com/hello"
  body         = <<BODY
@concat('{\"summary\": \"Foo\", \"text\": \"',triggerBody()?['data']?['essentials']?['description'],'\"}')
BODY
}
