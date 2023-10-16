

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-231016034213697571"
  location = "West Europe"
}

resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-231016034213697571"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2023-10-19T00:00:00Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "71212724-7a73-48c3-9399-de59313d4905@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}


resource "azurerm_logz_tag_rule" "test" {
  logz_monitor_id = azurerm_logz_monitor.test.id
}
