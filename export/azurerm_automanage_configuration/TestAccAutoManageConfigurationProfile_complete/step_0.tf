
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-230825024051418077"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-230825024051418077"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  antimalware {
    exclusions {
      extensions = "exe;dll"
      paths      = "C:\\Windows\\Temp;D:\\Temp"
      processes  = "svchost.exe;notepad.exe"
    }
    real_time_protection_enabled   = true
    scheduled_scan_enabled         = true
    scheduled_scan_type            = "Quick"
    scheduled_scan_day             = 1
    scheduled_scan_time_in_minutes = 1339
  }
  automation_account_enabled  = true
  boot_diagnostics_enabled    = true
  defender_for_cloud_enabled  = true
  guest_configuration_enabled = true
  status_change_alert_enabled = true
  tags = {
    "env" = "test"
  }
}
