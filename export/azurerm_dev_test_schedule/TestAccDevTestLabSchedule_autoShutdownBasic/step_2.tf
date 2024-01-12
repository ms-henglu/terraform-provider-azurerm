
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112224358794494"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctdtl-240112224358794494"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dev_test_schedule" "test" {
  name                = "LabVmsShutdown"
  status              = "Enabled"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  lab_name            = azurerm_dev_test_lab.test.name
  daily_recurrence {
    time = "0900"
  }
  time_zone_id = "India Standard Time"
  task_type    = "LabVmsShutdownTask"
  notification_settings {
    time_in_minutes = 30
    webhook_url     = "https://www.bing.com/2/4"
    status          = "Enabled"
  }
  tags = {
    environment = "Production"
  }
}
