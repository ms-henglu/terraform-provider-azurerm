
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-230512010404754624"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230512010404754624"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                = "acctestimg230512010404754624"
  gallery_name        = azurerm_shared_image_gallery.test.name
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  os_type             = "Linux"

  disk_types_not_allowed = [
    "Standard_LRS",
    "Premium_LRS",
  ]

  identifier {
    publisher = "AccTesPublisher230512010404754624"
    offer     = "AccTesOffer230512010404754624"
    sku       = "AccTesSku230512010404754624"
  }
}
