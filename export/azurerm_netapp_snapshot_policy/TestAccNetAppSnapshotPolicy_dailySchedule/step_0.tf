

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-221124182045580588"
  location = "East US 2"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-221124182045580588"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_netapp_snapshot_policy" "test" {
  name                = "acctest-NetAppSnapshotPolicy-221124182045580588"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  account_name        = azurerm_netapp_account.test.name
  enabled             = true

  daily_schedule {
    snapshots_to_keep = 1
    hour              = 22
    minute            = 15
  }
}
