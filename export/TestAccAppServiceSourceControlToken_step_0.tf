
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "wbpvnll81p0yhu2rv7h6qht8qgpplqa9fhj3pyfvo"
  token_secret = "qe9f4wxp1xdt1ja7xkvnmo1g4hxgr2hupk8afjdbu"
}
