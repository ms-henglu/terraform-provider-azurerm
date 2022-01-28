
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-datalake-220128052416577657"
  location = "West Europe"
}

resource "azurerm_data_lake_store" "test" {
  name                = "acctest012805241657765"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    environment = "staging"
  }
}
