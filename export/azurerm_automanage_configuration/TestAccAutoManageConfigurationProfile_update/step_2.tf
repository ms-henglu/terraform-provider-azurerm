
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311031406057779"
  location = "West Europe"
}


resource "azurerm_automanage_configuration" "test" {
  name                = "acctest-amcp-240311031406057779"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  antimalware {
    exclusions {
      extensions = "exe"
      processes  = "svchost.exe"
    }
    real_time_protection_enabled   = false
    scheduled_scan_enabled         = true
    scheduled_scan_type            = "Full"
    scheduled_scan_day             = 2
    scheduled_scan_time_in_minutes = 1338
  }
  tags = {
    "env2" = "test2"
  }
}
