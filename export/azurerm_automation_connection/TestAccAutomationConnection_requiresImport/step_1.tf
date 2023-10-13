


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-231013042959952686"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-231013042959952686"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_connection" "test" {
  name                    = "acctestAAC-231013042959952686"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  type                    = "AzureServicePrincipal"

  values = {
    "ApplicationId" : "00000000-0000-0000-0000-000000000000"
    "TenantId" : data.azurerm_client_config.test.tenant_id
    "SubscriptionId" : data.azurerm_client_config.test.subscription_id
    "CertificateThumbprint" : file("testdata/automation_certificate_test.thumb")
  }
}


resource "azurerm_automation_connection" "import" {
  name                    = azurerm_automation_connection.test.name
  resource_group_name     = azurerm_automation_connection.test.resource_group_name
  automation_account_name = azurerm_automation_connection.test.automation_account_name
  type                    = azurerm_automation_connection.test.type
  values                  = azurerm_automation_connection.test.values
}
