

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-240119024707322417"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig240119024707322417"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_gallery_application" "test" {
  name              = "acctest-app-240119024707322417"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_resource_group.test.location
  supported_os_type = "Linux"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestaccqqg6s"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "acctestscqqg6s"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "test" {
  name                   = "scripts"
  storage_account_name   = azurerm_storage_account.test.name
  storage_container_name = azurerm_storage_container.test.name
  type                   = "Page" # Use Page Blob as a workaround to UnmanagedStorageAccount quota issue
  size                   = 512
}



resource "azurerm_gallery_application_version" "test" {
  name                   = "0.0.1"
  gallery_application_id = azurerm_gallery_application.test.id
  location               = azurerm_gallery_application.test.location

  end_of_life_date = "2024-01-19T22:47:07Z"

  manage_action {
    install = "[install command]"
    remove  = "[remove command]"
  }

  source {
    media_link = azurerm_storage_blob.test.id
  }

  target_region {
    name                   = azurerm_gallery_application.test.location
    regional_replica_count = 1
  }
}
