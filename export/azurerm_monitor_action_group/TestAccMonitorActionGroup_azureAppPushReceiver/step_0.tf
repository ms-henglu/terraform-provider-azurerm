
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230804030334081716"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-230804030334081716"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  azure_app_push_receiver {
    name          = "pushtoadmin"
    email_address = "admin@contoso.com"
  }
}
