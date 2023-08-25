
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230825024235248940"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230825024235248940"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
