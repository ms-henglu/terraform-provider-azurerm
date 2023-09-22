
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestpubcert-230922062126115504"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acct230922062126115504"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestpubcert-230922062126115504"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "test" {
  name                       = "acctestpubcert-230922062126115504"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key
}

resource "azurerm_app_service_public_certificate" "test" {
  resource_group_name  = azurerm_resource_group.test.name
  app_service_name     = azurerm_function_app.test.name
  certificate_name     = "acctestpubcert-230922062126115504"
  certificate_location = "Unknown"
  blob                 = filebase64("testdata/app_service_public_certificate.cer")
}
