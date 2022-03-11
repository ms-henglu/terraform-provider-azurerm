
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220311033041410917"
  location = "West Europe"

  tags = {
    environment = "staging"
  }
}
