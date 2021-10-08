

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-211008044327892160"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-211008044327892160"
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
  name        = "acctest_ds_211008044327892160"
  account_id  = azurerm_data_share_account.test.id
  kind        = "CopyBased"
  description = "share desc 2"
  terms       = "share terms 2"
}
