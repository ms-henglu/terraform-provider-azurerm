

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-240119025505286856"
  location = "East US 2"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-240119025505286856"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_netapp_snapshot_policy" "test" {
  name                = "acctest-NetAppSnapshotPolicy-240119025505286856"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  enabled             = true

  monthly_schedule {
    snapshots_to_keep = 1
    days_of_month     = [1, 15, 30]
    hour              = 5
    minute            = 0
  }
}
