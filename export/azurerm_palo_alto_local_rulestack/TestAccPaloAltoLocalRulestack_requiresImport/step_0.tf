
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PALRS-231218072332098120"
  location = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-231218072332098120"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}

