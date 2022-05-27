

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-220527034059717747"
  location = "West Europe"
}

resource "azurerm_data_share_account" "test" {
  name                = "acctest-dsa-220527034059717747"
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
  name        = "acctest_ds_220527034059717747"
  account_id  = azurerm_data_share_account.test.id
  kind        = "CopyBased"
  description = "share desc"
  terms       = "share terms"
}
