
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220124122001735461"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest012412200173546"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    environment = "staging"
  }
}
