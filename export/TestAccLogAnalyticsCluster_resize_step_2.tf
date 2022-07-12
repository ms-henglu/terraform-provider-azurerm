

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-220712042442367323"
  location = "West Europe"
}


resource "azurerm_log_analytics_cluster" "test" {
  name                = "acctest-LA-220712042442367323"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size_gb             = 1100

  identity {
    type = "SystemAssigned"
  }
}
