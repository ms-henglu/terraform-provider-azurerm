
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "ljwv47nbpnaeniaj8973ovdpt2ol2vh2yeplizgnt"
  token_secret = "t2h9reyxojw44aron1194hxysha7w2eys4iiq1iih"
}
