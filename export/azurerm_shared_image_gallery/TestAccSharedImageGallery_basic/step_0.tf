
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230313020903883796"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230313020903883796"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
