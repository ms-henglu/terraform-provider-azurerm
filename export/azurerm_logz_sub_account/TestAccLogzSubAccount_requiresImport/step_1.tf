


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-240119025312467577"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-240119025312467577"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2024-01-19T09:53:12Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "429420d4-0abf-4cd8-b149-fe63fa141fc6@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_logz_sub_account" "test" {
  name            = "acctest-lsa-240119025312467577"
  logz_monitor_id = azurerm_logz_monitor.test.id
  user {
    email        = azurerm_logz_monitor.test.user[0].email
    first_name   = azurerm_logz_monitor.test.user[0].first_name
    last_name    = azurerm_logz_monitor.test.user[0].last_name
    phone_number = azurerm_logz_monitor.test.user[0].phone_number
  }
}


resource "azurerm_logz_sub_account" "import" {
  name            = azurerm_logz_sub_account.test.name
  logz_monitor_id = azurerm_logz_sub_account.test.logz_monitor_id
  user {
    email        = azurerm_logz_monitor.test.user[0].email
    first_name   = azurerm_logz_monitor.test.user[0].first_name
    last_name    = azurerm_logz_monitor.test.user[0].last_name
    phone_number = azurerm_logz_monitor.test.user[0].phone_number
  }
}
