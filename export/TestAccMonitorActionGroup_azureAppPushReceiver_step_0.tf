
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211008044703654823"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211008044703654823"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  azure_app_push_receiver {
    name          = "pushtoadmin"
    email_address = "admin@contoso.com"
  }
}
