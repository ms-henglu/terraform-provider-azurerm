

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-230609091532112359"
  location = "West Europe"
}


resource "azurerm_log_analytics_cluster" "test" {
  name                = "acctest-LA-230609091532112359"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size_gb             = 1000

  identity {
    type = "SystemAssigned"
  }
}
