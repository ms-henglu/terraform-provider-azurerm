
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-210830083908320307"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest083008390832030"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
