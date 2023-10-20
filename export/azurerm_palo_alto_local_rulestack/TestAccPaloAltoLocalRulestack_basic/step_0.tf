
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PALRS-231020041634709949"
  location = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-231020041634709949"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

