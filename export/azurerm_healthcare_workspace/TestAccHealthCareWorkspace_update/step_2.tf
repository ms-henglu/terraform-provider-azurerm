
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-221111013627581807"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk22111107"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location

  tags = {
    environment = "Prod"
  }
}
