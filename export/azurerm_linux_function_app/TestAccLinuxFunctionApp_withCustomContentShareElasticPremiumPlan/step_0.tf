
provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "test" {
  name     = "acctestRG-LFA-221124181226177530"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsa6qurk"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "test" {
  name                = "acctestASP-221124181226177530"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  os_type             = "Linux"
  sku_name            = "EP1"
  maximum_elastic_worker_count = 5
}


resource "azurerm_linux_function_app" "test" {
  name                = "acctest-LFA-221124181226177530"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  service_plan_id     = azurerm_service_plan.test.id

  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  app_settings = {
    foo                  = "bar"
    secret               = "sauce"
    WEBSITE_CONTENTSHARE = "test-acc-custom-content-share"
  }

  site_config {}
}
