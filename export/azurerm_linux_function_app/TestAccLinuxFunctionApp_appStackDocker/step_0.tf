
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-230929064322294191"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsaf1x9n"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-230929064322294191"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
  
}


resource "azurerm_linux_function_app" "test" {
  name                = "acctest-LFA-230929064322294191"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {
    always_on = true

    application_stack {
      docker {
        registry_url = "https://mcr.microsoft.com"
        image_name   = "azure-functions/dotnet"
        image_tag    = "3.0-appservice-quickstart"
      }
    }
  }
}
