

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-230512010942197220"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-230512010942197220"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2023-05-12T08:09:42Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "d5d750ce-94fd-475d-816f-48110e1ca04a@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
  enabled = false
}
