
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112225157590534"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
