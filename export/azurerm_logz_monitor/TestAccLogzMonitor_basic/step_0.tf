

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-logz-230915023706918452"
  location = "West Europe"
}


resource "azurerm_logz_monitor" "test" {
  name                = "acctest-lm-230915023706918452"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  plan {
    billing_cycle  = "MONTHLY"
    effective_date = "2023-09-15T09:37:06Z"
    usage_type     = "COMMITTED"
  }

  user {
    email        = "9d186100-1e0f-4b4a-bb10-753d2d52b750@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
