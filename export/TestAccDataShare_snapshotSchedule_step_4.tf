

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-211008044327893335"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-211008044327893335"
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
  name       = "acctest_ds_211008044327893335"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"

  snapshot_schedule {
    name       = "acctest-ss2-211008044327893335"
    recurrence = "Hour"
    start_time = "2021-10-08T12:43:27Z"
  }
}
