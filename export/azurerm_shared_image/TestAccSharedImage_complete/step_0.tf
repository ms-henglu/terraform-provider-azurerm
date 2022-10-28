
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-221028171853894074"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig221028171853894074"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                  = "acctestimg221028171853894074"
  gallery_name          = azurerm_shared_image_gallery.test.name
  resource_group_name   = azurerm_resource_group.test.name
  location              = azurerm_resource_group.test.location
  os_type               = "Linux"
  hyper_v_generation    = "V1"
  description           = "Wubba lubba dub dub"
  eula                  = "Do you agree there's infinite Rick's and Infinite Morty's?"
  privacy_statement_uri = "https://council.of.ricks/privacy-statement"
  release_note_uri      = "https://council.of.ricks/changelog.md"

  identifier {
    publisher = "AccTesPublisher221028171853894074"
    offer     = "AccTesOffer221028171853894074"
    sku       = "AccTesSku221028171853894074"
  }

  purchase_plan {
    name      = "AccTestPlan"
    publisher = "AccTestPlanPublisher"
    product   = "AccTestPlanProduct"
  }
}
