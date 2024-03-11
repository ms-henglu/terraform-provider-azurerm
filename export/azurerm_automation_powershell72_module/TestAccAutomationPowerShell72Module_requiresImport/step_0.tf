
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240311031415477153"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240311031415477153"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_powershell72_module" "test" {
  name                  = "xActiveDirectory"
  automation_account_id = azurerm_automation_account.test.id

  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/xactivedirectory.2.19.0.nupkg"
  }
}
