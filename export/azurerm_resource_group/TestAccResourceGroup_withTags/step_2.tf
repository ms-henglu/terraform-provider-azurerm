
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231218072455219715"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
