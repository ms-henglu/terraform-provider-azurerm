
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211013072134559565"
  location = "West Europe"
}

resource "azurerm_monitor_action_group" "test" {
  name                = "acctestActionGroup-211013072134559565"
  resource_group_name = azurerm_resource_group.test.name
  short_name          = "acctestag"

  webhook_receiver {
    name                    = "callmyapiaswell"
    service_uri             = "http://example.com/alert"
    use_common_alert_schema = true
  }
}
