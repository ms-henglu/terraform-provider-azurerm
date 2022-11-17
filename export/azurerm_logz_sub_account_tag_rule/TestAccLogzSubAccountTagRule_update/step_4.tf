

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-221117231114161463"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-221117231114161463"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-11-20T00:00:00Z"
    plan_id        = "100gb14days"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "a9c283cf-9045-40f0-aecf-d8738e5ed103@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}

resource "azurerm_logz_sub_account" "test" {
  name            = "acctest-lsa-221117231114161463"
  logz_monitor_id = azurerm_logz_monitor.test.id
  user {
    email        = azurerm_logz_monitor.test.user[0].email
    first_name   = azurerm_logz_monitor.test.user[0].first_name
    last_name    = azurerm_logz_monitor.test.user[0].last_name
    phone_number = azurerm_logz_monitor.test.user[0].phone_number
  }
}


resource "azurerm_logz_sub_account_tag_rule" "test" {
  logz_sub_account_id = azurerm_logz_sub_account.test.id
}
