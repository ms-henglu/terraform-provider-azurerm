
				
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctest-rg-231016034440100840"
  location = "West Europe"
}


resource "azurerm_new_relic_monitor" "test" {
  name                = "acctest-nrm-231016034440100840"
  resource_group_name = azurerm_resource_group.test.name
  location            = "West Europe"
  plan {
    effective_date = "2023-10-16T10:44:40Z"
  }
  user {
    email        = "d327e362-8431-4df1-8d99-8dc1c383a4f3@example.com"
    first_name   = "first"
    last_name    = "last"
    phone_number = "123456"
  }
}
