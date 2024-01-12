
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PALRS-240112225033859301"
  location = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-240112225033859301"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

