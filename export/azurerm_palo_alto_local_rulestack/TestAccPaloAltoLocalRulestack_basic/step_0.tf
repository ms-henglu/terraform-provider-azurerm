
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PALRS-230825025058131542"
  location = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-230825025058131542"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

