
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-appinsights-230929064313989248"
  location = "West Europe"
}

resource "azurerm_application_insights" "test" {
  name                                  = "acctestappinsights-230929064313989248"
  location                              = azurerm_resource_group.test.location
  resource_group_name                   = azurerm_resource_group.test.name
  application_type                      = "web"
  retention_in_days                     = 120
  sampling_percentage                   = 50
  daily_data_cap_in_gb                  = 50
  daily_data_cap_notifications_disabled = true
  disable_ip_masking                    = true
  force_customer_storage_for_profiler   = true
  local_authentication_disabled         = true

  tags = {
    Hello = "World"
  }
}
