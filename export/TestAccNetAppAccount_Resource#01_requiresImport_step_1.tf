

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-netapp-220610022916430010"
  location = "West Europe"
}

resource "azurerm_netapp_account" "test" {
  name                = "acctest-NetAppAccount-220610022916430010"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}


resource "azurerm_netapp_account" "import" {
  name                = azurerm_netapp_account.test.name
  location            = azurerm_netapp_account.test.location
  resource_group_name = azurerm_netapp_account.test.resource_group_name
}
