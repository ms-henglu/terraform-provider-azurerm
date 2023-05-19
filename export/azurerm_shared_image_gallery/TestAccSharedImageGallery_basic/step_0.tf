
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230519074408696742"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230519074408696742"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
