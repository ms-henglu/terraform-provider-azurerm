
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-maint-240315123422247058"
  location = "West Europe"
}

resource "azurerm_maintenance_configuration" "test" {
  name                = "acctest-MC240315123422247058"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  scope               = "InGuestPatch"
  visibility          = "Custom"

  window {
    start_date_time      = "5555-12-31 00:00"
    expiration_date_time = "6666-12-31 00:00"
    duration             = "02:00"
    time_zone            = "Pacific Standard Time"
    recur_every          = "2Days"
  }

  install_patches {
    reboot = "IfRequired"
    windows {
      classifications_to_include = ["Critical", "Security"]
    }
  }

  in_guest_user_patch_mode = "User"

}
