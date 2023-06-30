
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-230630033247562942"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk23063042"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
