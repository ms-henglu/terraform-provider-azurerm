

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-auto-230609090850703856"
  location = "West Europe"
}

data "azurerm_client_config" "test" {}

resource "azurerm_automation_account" "test" {
  name                = "acctestAA-230609090850703856"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku_name            = "Basic"
}

resource "azurerm_automation_certificate" "test" {
  name                    = "acctest-230609090850703856"
  resource_group_name     = azurerm_resource_group.test.name
  automation_account_name = azurerm_automation_account.test.name
  base64                  = filebase64("testdata/automation_certificate_test.pfx")
}


resource "azurerm_automation_connection_certificate" "test" {
  name                        = "acctestACC-230609090850703856"
  resource_group_name         = azurerm_resource_group.test.name
  automation_account_name     = azurerm_automation_account.test.name
  automation_certificate_name = azurerm_automation_certificate.test.name
  subscription_id             = data.azurerm_client_config.test.subscription_id
}
