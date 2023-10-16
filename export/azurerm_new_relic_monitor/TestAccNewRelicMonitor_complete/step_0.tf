
			
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016034440103917"
  location = "West Europe"
}


resource "azurerm_new_relic_monitor" "org" {
  name                = "acctest-nrmo-231016034440103917"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  plan {
    effective_date = "2023-10-16T10:44:40Z"
  }
  user {
    email        = "b9ba4f77-5e63-4f1e-9445-b982d35f635b@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}

resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-231016034440103917"
  resource_group_name = azurerm_new_relic_monitor.org.resource_group_name
  location            = azurerm_new_relic_monitor.org.location
  plan {
    billing_cycle  = azurerm_new_relic_monitor.org.plan[0].billing_cycle
    effective_date = "2023-10-16T10:44:40Z"
    plan_id        = azurerm_new_relic_monitor.org.plan[0].plan_id
    usage_type     = azurerm_new_relic_monitor.org.plan[0].usage_type
  }
  user {
    email        = azurerm_new_relic_monitor.org.user[0].email
    first_name   = azurerm_new_relic_monitor.org.user[0].first_name
    last_name    = azurerm_new_relic_monitor.org.user[0].last_name
    phone_number = azurerm_new_relic_monitor.org.user[0].phone_number
  }
  account_creation_source = azurerm_new_relic_monitor.org.account_creation_source
  account_id              = azurerm_new_relic_monitor.org.account_id
  ingestion_key           = "wltnimmhqt"
  organization_id         = azurerm_new_relic_monitor.org.organization_id
  org_creation_source     = azurerm_new_relic_monitor.org.org_creation_source
  user_id                 = "123456"
}
