
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "usst0fb6qcmpwwmemnqvvuxw8lsikfzjy3wl7wkf0"
  token_secret = "ywfae4nc1p9ntbybicm24kopd6rbe7cq231uqjjqs"
}
