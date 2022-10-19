
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221019054854770974"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
