
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240119024539563721"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240119024539563721"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_module" "test" {
  name                    = "xActiveDirectory"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name

  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/xactivedirectory.2.19.0.nupkg"
    hash {
      algorithm = "SHA256"
      value     = "5277774C7D6FC0E60986519D2D16C7100B9948B2D0B62091ED7B489A252F0F6D"
    }
  }
}
