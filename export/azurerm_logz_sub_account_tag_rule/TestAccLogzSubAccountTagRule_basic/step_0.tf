

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-230825024820349563"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-230825024820349563"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2023-08-28T00:00:00Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "72776074-85d8-47fc-a1c2-cd23693522da@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}

resource "azurerm_logz_sub_account" "test" {
  name            = "acctest-lsa-230825024820349563"
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
