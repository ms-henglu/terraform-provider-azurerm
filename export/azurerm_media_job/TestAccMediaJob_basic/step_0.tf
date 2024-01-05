

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-media-240105064206668008"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa1s4bdb"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_media_services_account" "test" {
  name                = "acctestmsas4bdb"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  storage_account {
    id         = azurerm_storage_account.test.id
    is_primary = true
  }
}

resource "azurerm_media_transform" "test" {
  name                        = "transform1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  output {
    relative_priority = "Normal"
    on_error_action   = "ContinueJob"
    builtin_preset {
      preset_name = "AACGoodQualityAudio"
    }
  }
}

resource "azurerm_media_asset" "input" {
  name                        = "inputAsset"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  description                 = "Input Asset description"
}

resource "azurerm_media_asset" "output" {
  name                        = "outputAsset"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  description                 = "Output Asset description"
}


resource "azurerm_media_job" "test" {
  name                        = "Job-1"
  resource_group_name         = azurerm_resource_group.test.name
  media_services_account_name = azurerm_media_services_account.test.name
  transform_name              = azurerm_media_transform.test.name
  input_asset {
    name = azurerm_media_asset.input.name
  }
  output_asset {
    name = azurerm_media_asset.output.name
  }
}
