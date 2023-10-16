


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PALRS-231016034505603015"
  location = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-231016034505603015"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}



resource "azurerm_palo_alto_local_rulestack" "import" {
  name                = azurerm_palo_alto_local_rulestack.test.name
  resource_group_name = azurerm_palo_alto_local_rulestack.test.resource_group_name
  location            = azurerm_palo_alto_local_rulestack.test.location
}

