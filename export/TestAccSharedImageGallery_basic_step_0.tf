
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924004029432472"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig210924004029432472"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
