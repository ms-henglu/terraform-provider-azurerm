


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-230922061614464239"
  location = "East US 2"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-230922061614464239"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_netapp_snapshot_policy" "test" {
  name                = "acctest-NetAppSnapshotPolicy-230922061614464239"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  enabled             = true

  hourly_schedule {
    snapshots_to_keep = 1
    minute            = 15
  }

  daily_schedule {
    snapshots_to_keep = 1
    hour              = 22
    minute            = 15
  }

  weekly_schedule {
    snapshots_to_keep = 1
    days_of_week      = ["Monday", "Friday"]
    hour              = 23
    minute            = 0
  }

  monthly_schedule {
    snapshots_to_keep = 1
    days_of_month     = [1, 15, 30]
    hour              = 5
    minute            = 0
  }
}


resource "azurerm_netapp_snapshot_policy" "import" {
  name                = azurerm_netapp_snapshot_policy.test.name
  location            = azurerm_netapp_snapshot_policy.test.location
  resource_group_name = azurerm_netapp_snapshot_policy.test.resource_group_name
  account_name        = azurerm_netapp_snapshot_policy.test.account_name
  enabled             = azurerm_netapp_snapshot_policy.test.enabled

  hourly_schedule {
    snapshots_to_keep = azurerm_netapp_snapshot_policy.test.hourly_schedule[0].snapshots_to_keep
    minute            = azurerm_netapp_snapshot_policy.test.hourly_schedule[0].minute
  }

  daily_schedule {
    snapshots_to_keep = azurerm_netapp_snapshot_policy.test.daily_schedule[0].snapshots_to_keep
    hour              = azurerm_netapp_snapshot_policy.test.daily_schedule[0].hour
    minute            = azurerm_netapp_snapshot_policy.test.daily_schedule[0].minute
  }

  weekly_schedule {
    snapshots_to_keep = azurerm_netapp_snapshot_policy.test.weekly_schedule[0].snapshots_to_keep
    days_of_week      = azurerm_netapp_snapshot_policy.test.weekly_schedule[0].days_of_week
    hour              = azurerm_netapp_snapshot_policy.test.weekly_schedule[0].hour
    minute            = azurerm_netapp_snapshot_policy.test.weekly_schedule[0].minute
  }

  monthly_schedule {
    snapshots_to_keep = azurerm_netapp_snapshot_policy.test.monthly_schedule[0].snapshots_to_keep
    days_of_month     = azurerm_netapp_snapshot_policy.test.monthly_schedule[0].days_of_month
    hour              = azurerm_netapp_snapshot_policy.test.monthly_schedule[0].hour
    minute            = azurerm_netapp_snapshot_policy.test.monthly_schedule[0].minute
  }
}
