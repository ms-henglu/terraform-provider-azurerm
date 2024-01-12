

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240112033911096404"
  location = "West Europe"
}

resource "azurerm_automation_account" "test" {
  name                = "acctest-240112033911096404"
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
  }
}


resource "azurerm_automation_module" "import" {
  name                    = azurerm_automation_module.test.name
  resource_group_name     = azurerm_automation_module.test.resource_group_name
  automation_account_name = azurerm_automation_module.test.automation_account_name

  module_link {
    uri = "https://devopsgallerystorage.blob.core.windows.net/packages/xactivedirectory.2.19.0.nupkg"
  }
}
