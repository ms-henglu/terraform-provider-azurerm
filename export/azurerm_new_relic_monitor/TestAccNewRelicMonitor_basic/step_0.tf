
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-240311032759429918"
  location = "West Europe"
}


resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-240311032759429918"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  plan {
    effective_date = "2024-03-11T10:27:59Z"
  }
  user {
    email        = "d327e362-8431-4df1-8d99-8dc1c383a4f3@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
