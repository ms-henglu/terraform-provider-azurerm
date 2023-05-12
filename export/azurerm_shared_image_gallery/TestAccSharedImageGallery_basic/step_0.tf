
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010404750886"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230512010404750886"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
