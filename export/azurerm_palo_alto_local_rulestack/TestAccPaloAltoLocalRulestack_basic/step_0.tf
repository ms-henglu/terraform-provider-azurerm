
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PALRS-231016034505600050"
  location = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-231016034505600050"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

