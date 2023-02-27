
provider "azurerm" {
  features {}
}

provider "azuread" {}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-vdesktop-230227175400538261"
  location = "westeurope"
}

resource "azurerm_role_definition" "test" {
  name        = "AVD-AutoScale2qr7x"
  scope       = azurerm_resource_group.test.id
  description = "AVD AutoScale Role"

  permissions {
    actions = [
      "Microsoft.Insights/eventtypes/values/read",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.DesktopVirtualization/hostpools/read",
      "Microsoft.DesktopVirtualization/hostpools/write",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/read",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/write",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/delete",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/sendMessage/action",
      "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read"
    ]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.test.id, # /subscriptions/00000000-0000-0000-0000-000000000000
  ]

  depends_on = [azurerm_resource_group.test]
}

data "azuread_service_principal" "test" {
  display_name = "Windows Virtual Desktop"
}

resource "azurerm_role_assignment" "test" {
  name                             = "74b96f85-7006-426a-882a-24e365ef0f4a"
  scope                            = azurerm_resource_group.test.id
  role_definition_id               = azurerm_role_definition.test.role_definition_resource_id
  principal_id                     = data.azuread_service_principal.test.application_id
  skip_service_principal_aad_check = true

  depends_on = [azurerm_role_definition.test]
}

resource "azurerm_virtual_desktop_host_pool" "test" {
  name                 = "acctestHP2qr7x"
  location             = azurerm_resource_group.test.location
  resource_group_name  = azurerm_resource_group.test.name
  type                 = "Pooled"
  validate_environment = true
  load_balancer_type   = "BreadthFirst"
}

resource "azurerm_virtual_desktop_scaling_plan" "test" {
  name                = "scalingPlan3271723778"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.test.name
  friendly_name       = "Scaling Plan Test"
  description         = "Test Scaling Plan"
  time_zone           = "GMT Standard Time"
  schedule {
    name                                 = "Weekdays"
    days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    ramp_up_start_time                   = "06:00"
    ramp_up_load_balancing_algorithm     = "BreadthFirst"
    ramp_up_minimum_hosts_percent        = 20
    ramp_up_capacity_threshold_percent   = 10
    peak_start_time                      = "09:00"
    peak_load_balancing_algorithm        = "BreadthFirst"
    ramp_down_start_time                 = "18:00"
    ramp_down_load_balancing_algorithm   = "DepthFirst"
    ramp_down_minimum_hosts_percent      = 10
    ramp_down_force_logoff_users         = false
    ramp_down_wait_time_minutes          = 45
    ramp_down_notification_message       = "Please log of in the next 45 minutes..."
    ramp_down_capacity_threshold_percent = 5
    ramp_down_stop_hosts_when            = "ZeroSessions"
    off_peak_start_time                  = "22:00"
    off_peak_load_balancing_algorithm    = "DepthFirst"
  }

  depends_on = [azurerm_role_assignment.test]


}
