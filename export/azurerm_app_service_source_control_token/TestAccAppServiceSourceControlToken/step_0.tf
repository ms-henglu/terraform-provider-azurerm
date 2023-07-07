
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "hu0y4nthg17ooc6n7s2fpq1y1nbefq1qsyafmanat"
  token_secret = "astmre9z8qvc82h81i87h1lwj1nlayy0hxpfmbkfz"
}
