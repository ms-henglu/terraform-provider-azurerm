

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-231016034213690934"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-231016034213690934"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2023-10-16T10:42:13Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "d5d750ce-94fd-475d-816f-48110e1ca04a@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
