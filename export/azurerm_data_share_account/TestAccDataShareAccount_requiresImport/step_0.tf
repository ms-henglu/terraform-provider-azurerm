

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-240119024907001507"
  location = "West Europe"
}


resource "azurerm_data_share_account" "test" {
  name                = "acctest-DSA-240119024907001507"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}
