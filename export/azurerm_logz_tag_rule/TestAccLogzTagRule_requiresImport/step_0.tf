

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-230316221825979468"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-230316221825979468"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2023-03-19T00:00:00Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "b993f18e-9094-4a38-9e80-a0530ebbc6e2@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_logz_tag_rule" "test" {
  logz_monitor_id = azurerm_logz_monitor.test.id
}
