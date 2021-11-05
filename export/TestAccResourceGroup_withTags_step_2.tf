
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211105040408760968"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
