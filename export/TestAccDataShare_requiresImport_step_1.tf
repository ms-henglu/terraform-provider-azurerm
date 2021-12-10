


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-211210034617766055"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-211210034617766055"
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
  name       = "acctest_ds_211210034617766055"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"
}


resource "azurerm_data_share" "import" {
  name       = azurerm_data_share.test.name
  account_id = azurerm_data_share_account.test.id
  kind       = azurerm_data_share.test.kind
}
