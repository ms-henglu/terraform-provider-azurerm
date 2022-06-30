
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "2irprq6ext9nx0gtz9i1ya3whtn1jq2rq8k001so2"
  token_secret = "ny80rcw2ubb0wf8otn6pntrpui1cighufcr7ehu3y"
}
