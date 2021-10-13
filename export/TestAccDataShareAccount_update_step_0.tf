

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datashare-211013071803637264"
  location = "West Europe"
}


resource "azurerm_data_share_account" "test" {
  name                = "acctest-DSA-211013071803637264"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  identity {
    type = "SystemAssigned"
  }
}
