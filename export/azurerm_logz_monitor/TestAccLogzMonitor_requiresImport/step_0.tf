

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-230929065159138236"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-230929065159138236"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2023-09-29T13:51:59Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "88841ffe-6376-487c-950c-1c3318f63dc5@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
