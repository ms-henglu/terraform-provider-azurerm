

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-211013071803638127"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-211013071803638127"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }

  tags = {
    env = "Test"
  }
}


resource "azurerm_data_share" "test" {
  name       = "acctest_ds_211013071803638127"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"

  snapshot_schedule {
    name       = "acctest-ss-211013071803638127"
    recurrence = "Day"
    start_time = "2021-10-13T14:18:03Z"
  }
}
