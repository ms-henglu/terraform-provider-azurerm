


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestrg-appliances-231013042915159872"
  location = "West Europe"
}


resource "azurerm_arc_resource_bridge_appliance" "test" {
  name                    = "acctestrcapplicance-231013042915159872"
  location                = azurerm_resource_group.test.location
  resource_group_name     = azurerm_resource_group.test.name
  distro                  = "AKSEdge"
  infrastructure_provider = "VMWare"
  public_key_base64       = "MIICCgKCAgEA7oaFVYSDpXlw+ZHyOyUB+8hxEnFeQowm01exg1EhoYwA+EtGqXurjwLoYgWIIjNc+g9V0CSWSzIdOLib+0UNoe+uB1gbpY+qtzEQQCIXeTiyvPC4oBkMnAkVGqQtrb2q1+CA7NurEBqlmytq6Ekukb31+1ECqn6w/1N+jneTF5WVS8cNWonvR8AJf23a1UqbOExqqrwRyqtZxB6ieq+++8uog9tRckl0ASfRi9KIJJcyfOc+7VPR1gWzY2zH8LaYwasA8Wd9tt+obViSEnV6lk6QBWyc0E7mzYi1fs1Hbc/SqEKRjjvlEmHhqCmCqMSifb/ZbYkzdVlL46xuApRsefTQA6eXSs7c0zGNNizfu6S0nUgoavUumkcR+RC7qZwoDHU5u5Nq6V7g7PqO0/37cBkPZAaj/XesmoI6yvgNs41sapPUfFs17vqvHjVHj1ka+N+/aQJNKXTweeehJthWfDCMJBS8dIMVXLF7vAODii2KpBHRFTwQ1c2p0YYXeMIJE3tf5poWhhgbUuG7iuArICz4Q2Uv8JbJAyPvYQrDKYHB4lGeGsJyxtO5kxZyLGKzrMe9zSbEEz+8FwvaXR2j6UjN2cbVRpy3ipBEEP32IX0aiFpWgWB5T4ogJxTuYVETX2vttzjfiluVGS6pfUznLJWM/MA0bim/V8pv4qw23j8CAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }
  tags = {
    "hello" = "world"
  }
}
