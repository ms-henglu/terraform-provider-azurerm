
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025423961477"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-240119025423961477"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  email_receiver {
    name                    = "sendtoadmin"
    email_address           = "admin@contoso.com"
    use_common_alert_schema = false
  }
}
