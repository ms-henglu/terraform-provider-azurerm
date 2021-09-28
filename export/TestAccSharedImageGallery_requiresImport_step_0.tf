
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-210928055247513743"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig210928055247513743"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}
