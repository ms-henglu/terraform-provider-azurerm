
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-health-240112224553553760"
  location = "West Europe"
}

resource "azurerm_healthcare_workspace" "test" {
  name                = "acctestwk24011260"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
