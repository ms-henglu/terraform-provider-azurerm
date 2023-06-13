
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230613071755261328"
  location = "West Europe"
}

resource "azurerm_dev_test_lab" "test" {
  name                = "acctdtl-230613071755261328"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_dev_test_schedule" "test" {
  name                = "LabVmAutoStart"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  lab_name            = azurerm_dev_test_lab.test.name
  weekly_recurrence {
    time      = "1000"
    week_days = ["Wednesday", "Thursday", "Friday"]
  }

  time_zone_id = "India Standard Time"
  task_type    = "LabVmsStartupTask"

  notification_settings {
  }

  status = "Enabled"

  tags = {
    environment = "Production"
  }
}
