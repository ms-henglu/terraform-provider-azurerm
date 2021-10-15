

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-211015014546724240"
  location = "West Europe"
}


resource "azurerm_data_share_account" "test" {
  name                = "acctest-DSA-211015014546724240"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }

  tags = {
    env = "Test"
  }
}
