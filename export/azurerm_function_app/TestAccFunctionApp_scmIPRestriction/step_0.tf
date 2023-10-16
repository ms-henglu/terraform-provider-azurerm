
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016034931012589"
  location = "West Europe"
}

resource "azurerm_storage_account" "test" {
  name                     = "acctestsadieqi"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "test" {
  name                = "acctestASP-231016034931012589"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "test" {
  name                       = "acctest-231016034931012589-func"
  location                   = azurerm_resource_group.test.location
  resource_group_name        = azurerm_resource_group.test.name
  app_service_plan_id        = azurerm_app_service_plan.test.id
  storage_account_name       = azurerm_storage_account.test.name
  storage_account_access_key = azurerm_storage_account.test.primary_access_key

  site_config {
    scm_ip_restriction {
      name        = "test-restriction"
      priority    = 123
      service_tag = "AzureEventGrid"
      headers {
        x_azure_fdid      = ["55ce4ed1-4b06-4bf1-b40e-4638452104da"]
        x_fd_health_probe = ["1"]
        x_forwarded_for   = ["9.9.9.9/32", "2002::1234:abcd:ffff:c0a8:101/64"]
        x_forwarded_host  = ["example.com"]
      }
    }
  }
}
