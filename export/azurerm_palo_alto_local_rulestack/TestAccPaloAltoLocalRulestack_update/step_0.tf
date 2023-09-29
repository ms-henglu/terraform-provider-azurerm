
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PALRS-230929065452015846"
  location = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-230929065452015846"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

