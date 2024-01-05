


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-240105060313946307"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-240105060313946307"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}


resource "azurerm_automation_connection_service_principal" "test" {
  name                    = "acctestACSP-240105060313946307"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  application_id          = "00000000-0000-0000-0000-000000000000"
  tenant_id               = data.azurerm_client_config.test.tenant_id
  subscription_id         = data.azurerm_client_config.test.subscription_id
  certificate_thumbprint  = file("testdata/automation_certificate_test.thumb")
}


resource "azurerm_automation_connection_service_principal" "import" {
  name                    = azurerm_automation_connection_service_principal.test.name
  resource_group_name     = azurerm_automation_connection_service_principal.test.resource_group_name
  automation_account_name = azurerm_automation_connection_service_principal.test.automation_account_name
  application_id          = azurerm_automation_connection_service_principal.test.application_id
  tenant_id               = azurerm_automation_connection_service_principal.test.tenant_id
  subscription_id         = azurerm_automation_connection_service_principal.test.subscription_id
  certificate_thumbprint  = azurerm_automation_connection_service_principal.test.certificate_thumbprint
}
