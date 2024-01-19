
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-maint-240119022352135544"
  location = "West Europe"
}

resource "azurerm_maintenance_configuration" "test" {
  name                     = "acctest-MC240119022352135544"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  scope                    = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  install_patches {
    reboot = "Always"
    linux {
      classifications_to_include = [
        "Critical",
        "Security",
      ]
      package_names_mask_to_exclude = []
      package_names_mask_to_include = []
    }

    windows {
      classifications_to_include = [
        "Critical",
        "Security",
        "UpdateRollup",
        "Definition",
        "Updates",
      ]
      kb_numbers_to_exclude = []
      kb_numbers_to_include = []
    }
  }

  window {
    duration        = "02:00"
    recur_every     = "Day"
    start_date_time = "2025-02-01 11:00"
    time_zone       = "Central Standard Time"
  }
}
