
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221021033910595472"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221021033910595472"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
