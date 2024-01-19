

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-240119024907002772"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-240119024907002772"
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
  name       = "acctest_ds_240119024907002772"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"

  snapshot_schedule {
    name       = "acctest-ss-240119024907002772"
    recurrence = "Day"
    start_time = "2024-01-19T09:49:07Z"
  }
}
