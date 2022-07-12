

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-220712042442361171"
  location = "West Europe"
}


resource "azurerm_log_analytics_cluster" "test" {
  name                = "acctest-LA-220712042442361171"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
