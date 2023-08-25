

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-compute-230825024235156050"
  location = "West Europe"
}

resource "azurerm_shared_image_gallery" "test" {
  name                = "acctestsig230825024235156050"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
}

resource "azurerm_gallery_application" "test" {
  name              = "acctest-app-230825024235156050"
  gallery_id        = azurerm_shared_image_gallery.test.id
  location          = azurerm_resource_group.test.location
  supported_os_type = "Linux"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestacc6ptjk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "acctestsc6ptjk"
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

  target_region {
    name                   = "West US 2"
    regional_replica_count = 3
    storage_account_type   = "Premium_LRS"
  }
}
