


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-230818023919654516"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-230818023919654516"
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
  name       = "acctest_ds_230818023919654516"
  account_id = azurerm_data_share_account.test.id
  kind       = "CopyBased"
}


resource "azurerm_data_share" "import" {
  name       = azurerm_data_share.test.name
  account_id = azurerm_data_share_account.test.id
  kind       = azurerm_data_share.test.kind
}
