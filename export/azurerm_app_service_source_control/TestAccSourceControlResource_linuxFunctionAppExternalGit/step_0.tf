

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-240119021457853813"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsas3qx0"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-240119021457853813"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "B1"
  
}


resource "azurerm_linux_function_app" "test" {
  name                = "acctest-LFA-240119021457853813"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {
    application_stack {
      python_version = "3.11"
    }
  }
}


resource "azurerm_app_service_source_control" "test" {
  app_id                 = azurerm_linux_function_app.test.id
  repo_url               = "https://github.com/Azure-Samples/flask-app-on-azure-functions.git"
  branch                 = "main"
  use_manual_integration = true
}
