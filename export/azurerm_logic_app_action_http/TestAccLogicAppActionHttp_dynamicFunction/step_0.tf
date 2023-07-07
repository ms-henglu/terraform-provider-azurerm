

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230707004214054995"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-230707004214054995"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_action_http" "test" {
  name         = "action230707004214054995"
  logic_app_id = azurerm_logic_app_workflow.test.id
  method       = "POST"
  uri          = "http://example.com/hello"
  body         = <<BODY
@concat('{\"summary\": \"Foo\", \"text\": \"',triggerBody()?['data']?['essentials']?['description'],'\"}')
BODY
}
