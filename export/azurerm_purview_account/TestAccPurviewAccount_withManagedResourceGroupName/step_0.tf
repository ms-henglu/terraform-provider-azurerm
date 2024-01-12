
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-purview-240112225117949699"
  location = "West Europe"
}


resource "azurerm_purview_account" "test" {
  name                        = "acctestsw240112225117949699"
  resource_group_name         = azurerm_resource_group.test.name
  location                    = azurerm_resource_group.test.location
  managed_resource_group_name = "acctestRG-purview-managed-240112225117949699"

  identity {
    type = "SystemAssigned"
  }
}
