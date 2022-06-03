
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-220603004640118544"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig220603004640118544"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_shared_image" "test" {
  name                  = "acctestimg220603004640118544"
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
    publisher = "AccTesPublisher220603004640118544"
    offer     = "AccTesOffer220603004640118544"
    sku       = "AccTesSku220603004640118544"
  }

  purchase_plan {
    name      = "AccTestPlan"
    publisher = "AccTestPlanPublisher"
    product   = "AccTestPlanProduct"
  }
}
