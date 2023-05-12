

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-230512010601748014"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-230512010601748014"
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
  name        = "acctest_ds_230512010601748014"
  account_id  = azurerm_data_share_account.test.id
  kind        = "CopyBased"
  description = "share desc"
  terms       = "share terms"
}
