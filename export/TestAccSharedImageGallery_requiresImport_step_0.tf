
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211217035034689160"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211217035034689160"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
