
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220627134437909042"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest062713443790904"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  tier                = "Commitment_1TB"
}
