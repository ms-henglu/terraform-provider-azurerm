

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-221221204513221458"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-221221204513221458"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2022-12-22T03:45:13Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "9d186100-1e0f-4b4a-bb10-753d2d52b750@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
