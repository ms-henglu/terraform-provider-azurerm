
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-211217035151682423"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest121703515168242"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    environment = "staging"
  }
}
