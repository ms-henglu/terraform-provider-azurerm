

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211210024740809681"
  location = "West Europe"
}

resource "azurerm_logic_app_workflow" "test" {
  name                = "acctestlaw-211210024740809681"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_logic_app_trigger_custom" "test" {
  name         = "recurrence-211210024740809681"
  logic_app_id = azurerm_logic_app_workflow.test.id

  body = <<BODY
{
  "recurrence": {
    "frequency": "Day",
    "interval": 1
  },
  "type": "Recurrence"
}
BODY

}
