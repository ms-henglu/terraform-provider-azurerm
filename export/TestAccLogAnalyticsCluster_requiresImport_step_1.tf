


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-220225034611352606"
  location = "West Europe"
}


resource "azurerm_log_analytics_cluster" "test" {
  name                = "acctest-LA-220225034611352606"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_log_analytics_cluster" "import" {
  name                = azurerm_log_analytics_cluster.test.name
  resource_group_name = azurerm_log_analytics_cluster.test.resource_group_name
  location            = azurerm_log_analytics_cluster.test.location

  identity {
    type = "SystemAssigned"
  }
}
