
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024442731515"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctdtl-230825024442731515"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dev_test_schedule" "test" {
  name                = "LabVmsShutdown"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  lab_name            = azurerm_dev_test_lab.test.name
  daily_recurrence {
    time = "0100"
  }
  time_zone_id = "India Standard Time"
  task_type    = "LabVmsShutdownTask"
  notification_settings {
  }

  tags = {
    environment = "Production"
  }
}
