

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-220712042207974113"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-220712042207974113"
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
  name        = "acctest_ds_220712042207974113"
  account_id  = azurerm_data_share_account.test.id
  kind        = "CopyBased"
  description = "share desc"
  terms       = "share terms"
}
