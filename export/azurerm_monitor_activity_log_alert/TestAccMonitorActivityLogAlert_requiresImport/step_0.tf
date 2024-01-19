
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240119025423961232"
  location = "West Europe"
}

resource "azurerm_monitor_activity_log_alert" "test" {
  name                = "acctestActivityLogAlert-240119025423961232"
  resource_group_name = azurerm_resource_group.test.name
  scopes              = [azurerm_resource_group.test.id]

  criteria {
    category = "Recommendation"
  }
}
