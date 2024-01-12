
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-240112033847481691"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-240112033847481691"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "test" {
  name                = "acctestpip-240112033847481691"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112033847481691"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.test.id
  }
}

resource "azurerm_network_security_group" "my_terraform_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.test.id
  network_security_group_id = azurerm_network_security_group.my_terraform_nsg.id
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctestVM-240112033847481691"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd6658!"
  provision_vm_agent              = false
  allow_extension_operations      = false
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.test.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-240112033847481691"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAuR0cC7t/EkrBpkVN6Tb5XipeodSQp0do4X3P+CqlN8U00o19pIAesyDsUfksj+RJnoezpOj8CHypfxeuTHawq3oBEbTL8TDlmLf+gMaG75lR/IKiywFBF0YNaizUnNdiMJYYxl1SGWbjQB9vxOF4mlIEhVkYGknWe/k7HBnb8vK3pEFV1zYLFRjWJSWQKmg2lZcmLIDZeGenseyyJYBCRcc3wINvnWyY8QvYQhbBFeKmF2B4OgS+lTAuDkZVXsUlCgbfQrxaODv7VwBL1BQNM/PKFYG3idSdwpIhUaPl/r2e81Knm/xyiGwJyD5NcXCKPAyvfRgO5VKnzRyv0PTSo8fi6QuuXk1d9mDsP/cH5LzJHU+vzaweRYrh70r3LUvxyt6FMu7T9U+sWszQOG+6jlU9sOU4TWRi0eVyfqtzgY9ur478ewqOzGfAkHdvCOv8gyAUT9j3Jkboeq7EQj0KR9n4bNsnlgk2bYY6WMxRncBx2ra9hbuQPXtV6ihjLgSNbqV731fA/+hLsW4ru7HwkaBD72Hs71oHUuy6jnfhjn7l/kvoUu9xAOVPSe2wR6velW9I9T9kNtj1YNMPoDnk/Vk7dinWfVfYrxiZXoA7LvM1zlm3ivSjEkAjVpuwf8SIXKg/lBOVkdwK38QioyvCvkb3AtfwdIZbQO14qMK5lXcCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd6658!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-240112033847481691"
    location            = azurerm_resource_group.test.location
    tenant_id           = "ARM_TENANT_ID"
    working_dir         = "/home/adminuser"
  })
  destination = "/home/adminuser/install_agent.sh"
}

provisioner "file" {
  source      = "testdata/install_agent.py"
  destination = "/home/adminuser/install_agent.py"
}

provisioner "file" {
  source      = "testdata/kind.yaml"
  destination = "/home/adminuser/kind.yaml"
}

provisioner "file" {
  content     = <<EOT
-----BEGIN RSA PRIVATE KEY-----
MIIJKgIBAAKCAgEAuR0cC7t/EkrBpkVN6Tb5XipeodSQp0do4X3P+CqlN8U00o19
pIAesyDsUfksj+RJnoezpOj8CHypfxeuTHawq3oBEbTL8TDlmLf+gMaG75lR/IKi
ywFBF0YNaizUnNdiMJYYxl1SGWbjQB9vxOF4mlIEhVkYGknWe/k7HBnb8vK3pEFV
1zYLFRjWJSWQKmg2lZcmLIDZeGenseyyJYBCRcc3wINvnWyY8QvYQhbBFeKmF2B4
OgS+lTAuDkZVXsUlCgbfQrxaODv7VwBL1BQNM/PKFYG3idSdwpIhUaPl/r2e81Kn
m/xyiGwJyD5NcXCKPAyvfRgO5VKnzRyv0PTSo8fi6QuuXk1d9mDsP/cH5LzJHU+v
zaweRYrh70r3LUvxyt6FMu7T9U+sWszQOG+6jlU9sOU4TWRi0eVyfqtzgY9ur478
ewqOzGfAkHdvCOv8gyAUT9j3Jkboeq7EQj0KR9n4bNsnlgk2bYY6WMxRncBx2ra9
hbuQPXtV6ihjLgSNbqV731fA/+hLsW4ru7HwkaBD72Hs71oHUuy6jnfhjn7l/kvo
Uu9xAOVPSe2wR6velW9I9T9kNtj1YNMPoDnk/Vk7dinWfVfYrxiZXoA7LvM1zlm3
ivSjEkAjVpuwf8SIXKg/lBOVkdwK38QioyvCvkb3AtfwdIZbQO14qMK5lXcCAwEA
AQKCAgEAiglg7obEPPmt6bToYi3ySfvCUV7W90ZSuUM+H8p9JVdTCmcj99TqD51P
W9k5F5ueIi8DEMgDmLiNFA6ulKo1F8mEnpV5NsPFkdoyWAiyelyUPH2Vs1eeGCLO
wgvoB4S83Yovs0vHetW0RA6tI90WN81NPbqwNHo3DH9PSqcl0saXlk56Gl9caED6
/vxBwr2vZmEtwCXdBOIWtKDSPxCjWrExq8bXJkbizWyNuMqK9SzruabgQDNlgo5I
6bAc3OyZsB5rwbH+fMyNodTAtsa1CbaTTPJL0OXRNlQNsHlNemYf70YFYlYfegdG
TCHZUewfyKOVAO09vleidVsc5+6IWwB4zgPgBTFBe5/AtguDLHxtsR+wEM/ALySz
tAUE8IaR2ypbRHBsY1baF7rq8cUH4qNp+uCjlSmaHNcwP0+wHduM+NUHMXW9srL+
nLbvsQRR4qVetmQftgj4fjI8V76gTqEkQq6SS5dijWooBbT/KB1kASCtHKEl3yT8
Npd2tQjALjoBVUR51+VZXmeEu37SQfnGt/bbk5pTGzWWx/QzH3ahOY2SA52oscUF
wCWiwmAA2ogLqtutUBOs40myTe0N4LOSNAffuvyYnKUp8/deaFgtyOlT+0WKtvwV
xO43GuHfHL8pK65yvYuRSHD0nFrHSgYNkIeRy5UpOt4G4uNc/hECggEBANfzak7s
9y/H/vPAV6tMRH359WmzU6u3qlJjdCaBNT63Xwlvi7T+z4rGuvFU8ggf6WRcsU6j
pN7iwAd13E4QuOSpaPvqanm/jmmpfd+Q1t2D4KekVWATJwCpQxjrDa4cFyMI+r82
+vi9TVzk9MZNzcnouai+IvID4LJsIb2H6BfpjWXYo1Y9KEzYw3y6WIikbijw1JCR
+MggBt3GKKxRHbcrO6RVrUK0QgsPhnlxl+oATQSqYEJQyC9BFJVKsJi0IdzNDKm4
NoZDqtCivegB/Kz+V6CE6iyVEW2i3lNaB0KsguNzdbQwtU5w8sa3+rkFScqrN5HP
kAztWfNzM46Y9JMCggEBANtxp+2ujKsKKOmKIEhVAYY3zNvD4N+9TrRDIwS7bAAu
wGD6i68gUdP0f5gUttogpNxctOVidGICPczHPfH7IQep8JTEhgbAQhB7AGsb6hob
L+6I9M91rQc0lmrT9461zDa588acpNyfcgtSD1A9An1ZpUn504wm2feh7MYExN/S
GSmDU3GG4OeDoXfwE+LKPklWowShjaKULUN23ggwC6YwlMsnfAgCYzwQESyMLDem
+SJOxpFvxp7ofPHbUQEQmcSkmZ6w1OyHzIu8CQfZ/CXv4XcocQU1LFFRukaekO8Z
o7JZIbIdzC/RvvbU6sT2sifAKsDaCuCO9NIDBb1qbg0CggEBALl5d3USUbvYKkFw
kduuRaVtajq+qr5xoPfiM4BeuTyEgju4cmWh9N9ckHN2YepYfjyU4DSKmLBWUFgY
An+KHUNHvcOgMpMe01ItIM9Dt0fKXMmfezRpPrZyqg5c1AMWXUjaDYLt1eCNtkRy
4Ujwyi8Ak3U62QjEC9kyxkfi0pS3I5q11pPbMyHNixk1c5TopTTEo80HkoVP/JW9
/HEDumH33+HlNEp2R8L4MqdbyP5SA9ReAQ70EvuDCgqve72r+OmLs7SRY0MuGyfW
nwUFr99lFB3qCrb/0Vg46nrseA/r2v8/y3hX3WDh4aKLoewHfrlzFOdHPpHbycYu
y7lN5cECggEBAJRaqB7FjI/tVG9eVCjSXy9v9ez05cgc4WJ4qOoAEymkcaaee2Sv
wuI6PzB/gIbC3vGjMyCIiQnhXgpdAIHhNxlJSD4rBjj2LTObFFNVEdUIYEUxDeBb
O9jNMouSNaCjQyYUXLv/Fm2Y1a7VkUi7lj1MJ7R1UxFDCsShEcNlYfu2vBAWmoj7
mHyrvrOo+Kiv9Z/7FEaDOY+aAWfEqqJ6aMW3vkABt5Zqls/6RMILGbGeDnulKhUU
rgCsSBvyGzdPE8WfScPA5JHr1Nr7ClfmhNLY82JtUsskgYuQZxBrDqy2draSD3et
MWd6s1GH7BeweAzrm3u5bPUXcGeyZ2UA2NkCggEACn58MU/dK4rwuIN/8jfBc2JO
8gv+ZeJuSSVeqJefmN5VjQyNEWDUwKhGtKMtUXIBRLy2Zfsdv7ntTDxjD++wAZM/
/hJd7celnq8oyp/EZUm8Qb8xl2ALk2WrbqGkQ7N8nMGpxVdIs56YlNaL8dKXtAaK
dDAP5E/nDhGwTt2PADzZT2IqMfw3iQkyRpLyiWEnQOffRBoJEbY6TiFvfaeV8u2S
Agt7ZBk3ZJ3ecfhb1JHxueW7vZhGlDxSGs4GurCvgIU8ndXNB8CDcSrY3X3xbl4J
j4OcGctzDuMEhbWNaGgfxo2LRufI/7XpUMy0Z45e4jkwCOqtGzgU/gIQFjpgQA==
-----END RSA PRIVATE KEY-----

EOT
  destination = "/home/adminuser/private.pem"
}

provisioner "remote-exec" {
  inline = [
    "sudo sed -i 's/\r$//' /home/adminuser/install_agent.sh",
    "sudo chmod +x /home/adminuser/install_agent.sh",
    "bash /home/adminuser/install_agent.sh > /home/adminuser/agent_log",
  ]
}


  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_arc_kubernetes_cluster_extension" "test" {
  name           = "acctest-kce-240112033847481691"
  cluster_id     = azurerm_arc_kubernetes_cluster.test.id
  extension_type = "microsoft.flux"

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_linux_virtual_machine.test
  ]
}


resource "azurerm_storage_account" "test" {
  name                     = "sa240112033847481691"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc240112033847481691"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "test" {
  connection_string = azurerm_storage_account.test.primary_connection_string
  https_only        = true
  signed_version    = "2019-10-10"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2024-01-11T03:38:47Z"
  expiry = "2024-01-14T03:38:47Z"

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = false
  }
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-240112033847481691"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    sas_token    = data.azurerm_storage_account_sas.test.sas
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test
  ]
}
