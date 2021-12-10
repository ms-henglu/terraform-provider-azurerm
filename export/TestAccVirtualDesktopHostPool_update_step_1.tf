
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-211210034633561695"
  location = "West US 2"
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                     = "acctestHPm3nfj"
  location                 = azurerm_resource_group.test.location
  resource_group_name      = azurerm_resource_group.test.name
  type                     = "Pooled"
  friendly_name            = "A Friendly Name!"
  description              = "A Description!"
  validate_environment     = true
  start_vm_on_connect      = true
  load_balancer_type       = "BreadthFirst"
  maximum_sessions_allowed = 100
  preferred_app_group_type = "Desktop"
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"

  # Do not use timestamp() outside of testing due to https://github.com/hashicorp/terraform/issues/22461
  registration_info {
    expiration_date = timeadd(timestamp(), "48h")
  }
  lifecycle {
    ignore_changes = [
      registration_info[0].expiration_date,
    ]
  }

  tags = {
    Purpose = "Acceptance-Testing"
  }
}
