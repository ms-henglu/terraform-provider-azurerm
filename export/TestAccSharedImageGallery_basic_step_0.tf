
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-211015014023151221"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig211015014023151221"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
