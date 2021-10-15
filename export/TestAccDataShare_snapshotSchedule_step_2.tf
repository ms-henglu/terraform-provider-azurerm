

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-211015014546739574"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-211015014546739574"
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
  name       = "acctest_ds_211015014546739574"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"

  snapshot_schedule {
    name       = "acctest-ss-211015014546739574"
    recurrence = "Day"
    start_time = "2021-10-15T08:45:46Z"
  }
}
