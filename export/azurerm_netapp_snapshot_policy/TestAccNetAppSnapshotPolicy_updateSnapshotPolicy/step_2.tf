

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-231016034408433064"
  location = "East US 2"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-231016034408433064"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_netapp_snapshot_policy" "test" {
  name                = "acctest-NetAppSnapshotPolicy-231016034408433064"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  enabled             = true

  hourly_schedule {
    snapshots_to_keep = 5
    minute            = 15
  }

  daily_schedule {
    snapshots_to_keep = 1
    hour              = 20
    minute            = 15
  }

  weekly_schedule {
    snapshots_to_keep = 1
    days_of_week      = ["Monday", "Tuesday", "Friday"]
    hour              = 23
    minute            = 0
  }

  monthly_schedule {
    snapshots_to_keep = 1
    days_of_month     = [1, 30]
    hour              = 5
    minute            = 30
  }
}
