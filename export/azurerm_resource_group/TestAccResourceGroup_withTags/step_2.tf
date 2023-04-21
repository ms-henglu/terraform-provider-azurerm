
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230421022818979230"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
