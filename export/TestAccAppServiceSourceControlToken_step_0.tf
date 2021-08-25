
provider "azurerm" {
  features {}
}

resource "azurerm_app_service_source_control_token" "test" {
  type         = "GitHub"
  token        = "dsuucewpx28s9nt17ubzjd7q0btkvn0lx9tn4kvy8"
  token_secret = "v6pbc46re9ip3cq4mkp6up38jdulknz33ny81ngh7"
}
