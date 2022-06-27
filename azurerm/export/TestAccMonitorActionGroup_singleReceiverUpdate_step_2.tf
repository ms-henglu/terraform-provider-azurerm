
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220627132132160058"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-220627132132160058"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  itsm_receiver {
    name                 = "createorupdateticket"
    workspace_id         = "6eee3a18-aac3-40e4-b98e-1f309f329816"
    connection_id        = "53de6956-42b4-41ba-be3c-b154cdf17b13"
    ticket_configuration = "{}"
    region               = "eastus"
  }
}
