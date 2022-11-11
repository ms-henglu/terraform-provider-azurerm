

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-la-221111013756806728"
  location = "West Europe"
}


resource "azurerm_log_analytics_cluster" "test" {
  name                = "acctest-LA-221111013756806728"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  identity {
    type = "SystemAssigned"
  }
}
