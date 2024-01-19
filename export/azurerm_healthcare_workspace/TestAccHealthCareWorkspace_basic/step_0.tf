
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-240119025124511518"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk24011918"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
