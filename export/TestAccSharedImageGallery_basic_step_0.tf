
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210924010808662635"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig210924010808662635"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
