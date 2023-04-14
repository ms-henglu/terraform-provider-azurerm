
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230414022046320214"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
