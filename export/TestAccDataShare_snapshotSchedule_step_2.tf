

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-220916011356899561"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-220916011356899561"
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
  name       = "acctest_ds_220916011356899561"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"

  snapshot_schedule {
    name       = "acctest-ss-220916011356899561"
    recurrence = "Day"
    start_time = "2022-09-16T08:13:56Z"
  }
}
