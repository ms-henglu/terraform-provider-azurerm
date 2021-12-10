
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211210024515406042"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest121002451540604"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    environment = "Production"
    cost_center = "MSFT"
  }
}
