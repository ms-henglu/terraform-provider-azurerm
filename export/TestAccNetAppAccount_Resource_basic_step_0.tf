
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-210928055730539427"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-210928055730539427"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}
