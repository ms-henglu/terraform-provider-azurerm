


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-PALRS-240105061331689486"
  location = "West Europe"
}


resource "azurerm_palo_alto_local_rulestack" "test" {
  name                = "testAcc-palrs-240105061331689486"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
}



resource "azurerm_palo_alto_local_rulestack" "import" {
  name                = azurerm_palo_alto_local_rulestack.test.name
  resource_group_name = azurerm_palo_alto_local_rulestack.test.resource_group_name
  location            = azurerm_palo_alto_local_rulestack.test.location
}

