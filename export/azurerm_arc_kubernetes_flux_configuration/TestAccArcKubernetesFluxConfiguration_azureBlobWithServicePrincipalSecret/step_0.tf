
				
				
				
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-231016033406953045"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctestnw-231016033406953045"
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
  name                = "acctestpip-231016033406953045"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-231016033406953045"
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
  name                            = "acctestVM-231016033406953045"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1986!"
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
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}


resource "azurerm_arc_kubernetes_cluster" "test" {
  name                         = "acctest-akcc-231016033406953045"
  resource_group_name          = azurerm_resource_group.test.name
  location                     = azurerm_resource_group.test.location
  agent_public_key_certificate = "MIICCgKCAgEAxJdL+yRVkdp1Kx0aejl/1X63yL0xv/m2kW3NgZoI0PQfiZDKNY0fNwg/OcbJKQul2Ge1b/NqIzizuULGA0lgC5mEK6vHYbyuarYqLJu2tOIHITPEab+rTGx2RZTnrsrdIlhCFNmg0nFXPWM31wu79rZG1fr+FqDGI5ExnMzTYOdnLZ/NwbjNty5PwB0td5aBFUw4Afc1YIc4ojOzMpWH/+KklsmDPwvSOpqnKsvTKKAxwZ1POjheaB9jrAhxIfEfLDaqX/0wi1OB31Ekjl684zkpfl6f9YRxegiG14iN8rD7bwpJQQ/KuvTu2hAhjjx1Rhjczp7FybxJb9DKilZdxI0sko1XHDmFCrml+oTcxbL/cqKLG0NBq5bTbHGCSykVAOge9c6hK0xTQ15HhDk69BzrM+eDLkz0Ig2xO2+HXpNB96CntIbjkFAFRWU2LqlzHjpTCG5K3njOokFGMTQbKQDNrclPwAcCeRa+9BE3aCYD1gRgz/L1qyi0KTeff+6h1oQzGOfxoudj/h8BDsDEhA+SpjOGo6MUtVxwXEbShflZQMKh0bs3WD+FFHvjN1t4fLm5YVEPG5HU33Q/YZNoTo+1l5N5yhZ+EPxe7ikD+tM0Miz4EQ+UcmlZZHzyG/s5HJsZbnoyDqgi36D1dZIiU5KqjiQM+iePoFTpNy36WkkCAwEAAQ=="
  identity {
    type = "SystemAssigned"
  }

  
connection {
  type     = "ssh"
  host     = azurerm_public_ip.test.ip_address
  user     = "adminuser"
  password = "P@$$w0rd1986!"
}

provisioner "file" {
  content = templatefile("testdata/install_agent.sh.tftpl", {
    subscription_id     = "ARM_SUBSCRIPTION_ID"
    resource_group_name = azurerm_resource_group.test.name
    cluster_name        = "acctest-akcc-231016033406953045"
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
MIIJKwIBAAKCAgEAxJdL+yRVkdp1Kx0aejl/1X63yL0xv/m2kW3NgZoI0PQfiZDK
NY0fNwg/OcbJKQul2Ge1b/NqIzizuULGA0lgC5mEK6vHYbyuarYqLJu2tOIHITPE
ab+rTGx2RZTnrsrdIlhCFNmg0nFXPWM31wu79rZG1fr+FqDGI5ExnMzTYOdnLZ/N
wbjNty5PwB0td5aBFUw4Afc1YIc4ojOzMpWH/+KklsmDPwvSOpqnKsvTKKAxwZ1P
OjheaB9jrAhxIfEfLDaqX/0wi1OB31Ekjl684zkpfl6f9YRxegiG14iN8rD7bwpJ
QQ/KuvTu2hAhjjx1Rhjczp7FybxJb9DKilZdxI0sko1XHDmFCrml+oTcxbL/cqKL
G0NBq5bTbHGCSykVAOge9c6hK0xTQ15HhDk69BzrM+eDLkz0Ig2xO2+HXpNB96Cn
tIbjkFAFRWU2LqlzHjpTCG5K3njOokFGMTQbKQDNrclPwAcCeRa+9BE3aCYD1gRg
z/L1qyi0KTeff+6h1oQzGOfxoudj/h8BDsDEhA+SpjOGo6MUtVxwXEbShflZQMKh
0bs3WD+FFHvjN1t4fLm5YVEPG5HU33Q/YZNoTo+1l5N5yhZ+EPxe7ikD+tM0Miz4
EQ+UcmlZZHzyG/s5HJsZbnoyDqgi36D1dZIiU5KqjiQM+iePoFTpNy36WkkCAwEA
AQKCAgEArd/TB/D+7d11vAglnuy0L7PAAP+0vMKzwrSHCpWeLpF8Q0OYVPzYGuhk
Y0l6KZ9vs5MmWjnEKhrAep6gW8/N7vR8fdOUqNEkwqUTcBjY4+r1u1v54D3x18om
YSxuLZ6nLvU4nRBOuVIdguH6RWzPdkmJJUC08naISHTmmHRgkFiaXTP1290DtXx0
dMpZqGepC5k6ACMRRqrSYEOxvo+alatzPxpDxsNB0Stvpt5XiJsG5uOnayrn9Neu
ZD2jMg39MDG5RuS8xr25JDa0SmdoUOAB3w76E0BszS41dPQF+ByohXFnkO/SssBn
cN7Lju3SG4lp4iVzchXiLc9RFEGG8/8pmrbSsorWbreuMwiGuMKtnr3KPgnNZO7w
ICrxQ7fchq/AkUIm9w5WEix03lRHHV41aoVjO+mXRgXdkLg1voysRbZZHaxHCJK6
ROQo4sfyN3JwsJCP/rTDWGv08tUdbCzPKdZSUA41YvpETtCkf7how7Cevgq0mHQT
aF513wZnJiFQIvcTF5+FVA8N8BV+CJAFd/TW6reZb6b3qBsKYqqQbP0fzlOHOipO
HrB9SSWMO//farcNznQBhJXgT8VAEmvXhBNku5VVPpX2NNlJzXSYHx8ruruWPrsJ
iAhVOAPJOpWAS1HPAMv70rlzqrprEbLUzOVToZg2O5+4j3OJKAECggEBANRXAUi2
IR6FDnAi4djseZOme9YbsfM8GzNDt6ERCv1Af7GmfVz3+c+XhPEMhzsCYCtzUyvB
5jFCfLJrEKBojHALhzaySxRA+FYiQmTGbZfXWRDeTp2fFjIcDgWOiz301ZJBg/N8
JBRAw5Z00kdBGEi6I6T+wD09za45qPoTsZtbZBqm4FOVvggfuOVUb5Ey6skZGIZ8
zClBWUcJaA4xqBbyIpAiBFf+Ugk4SvRn0YkCkZm4rMmfKrdR7dQyfiHRH3zfajxE
wMPai6gie+T0BJGIznhjXTmwzSOhwjrp/u91LOWIKuovxW+995X/jqM2kfbn6Nc1
EiIof/TZw/UTq8ECggEBAO0DUICLz5G/VpZNgMQiLku7ZLzQYa483VdU6tdlgjPH
XhddIvIOspXrmWMltLc/7/pcFfd+f3hfw9xl0EMkBSoSg2k9UCBFwRze7rpY3RDh
N+sTg3NtOtHu2cUwb+BZO+iI/U9edFsswrMDIIND6u8KSuVaMCx+YhziSZvEdGdI
BFCcXdvKryNLdl7sYfmkcH4mRn0miJFbMqwh+MjqFdi1RmGBW/3Y+9FRrSVYw8+l
Rkgkjld0KAjZk3MfE8n+G7Y9ZpVw//Ncku97jheezFeD+kJkXAmumgNqRyU6+QUw
Jg5PNOPuNK3V/jnReUU2Sgkez6d35UiWgf1b3BsPcIkCggEBANJJ+DOSa+pVy56y
bQjv6NeZITtB4lIJTMbQYaNZxZBZuByvzaeszfIRFM/EoIiIKcXeSJglR1uxhN0N
u0GhSLQONrKskD5WuZpUA3zaJt8hnkteXm0riEfIEPrf2HZbaseVqqAQaYrFOO5g
c3+tr+cWsQZOZQRBmNjascY4isRZFiJu8erVeYWCJRK5NGSQEIVoHSnTnj2dQlVf
s3WbJ+TRl/k2NycN7yDCZzj1OEaADMI4aqaiwyMaOHbWKqRC/vQkLonRbTaJ0ZWJ
0TlFkOCwpAoGHeVsezy2jizaYGe1m+kVmaqj9NxdPj2HAjQRby0fLzEylerOQSq0
H6Uu/gECggEBAK/wGu0hW9ccSuFN7P0rRmSPWctTgH8/zSrL7XwxbQKUx0Ler1cy
E914Q6e20LyLKNAXVXMgIu2vYQwVRBDjBzZhAc24ZudeAGk3D82is4+ZL9I/7P9d
ISG/hUZ8mz/V3cPTFP665fLcejc6ZgMrApWpdUlltocA1kIMtIl9vs8ARbu1J3NF
tNalaNwz6tLO/3aVYRP767rDEQ14Nl6mbcstXW56AVihnuSWFcq4ZrqYPGDHSiaf
IizXnj4B3sW97MJON/1NIaJ8oNJHTIY6KgP5A2gPaccCJm/Mj72SVlJEmKtcnq1o
IRC93nb7CWOYVkMI7SqqtLg6iYoSi4RG5MkCggEBALGstf8UHV+z9VXZ6wmEMS8/
GedRt31Xg9BTUcJ0IrtuwBJx/Qj0I5EAKi+XswhD5ce0aH1QwNgrg/SSQkQjRm5M
1/hr2Zpvp5FOq49ssxruufq/8LzmcCRLREDIHUetyr4sLTaa+Dq4Ewm0rfee9Bvy
uGfQIpgOuayHGRwMatsMQJx8nqinoBYZLspmuyPAxnxx5cFSRZDytlxqXsImfD6B
MPIHwum4O9/v+IQvEMcnQFb7M6ikf6g4SYPfNcgos0zuvKgokgMSQOpeDcUF5F3F
33K6DUOwVruEsuUnNge2CQ0D66QpBcdxFJE0SCNS9TGup1XYK0uokstCG+tZT94=
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
  name           = "acctest-kce-231016033406953045"
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
  name                     = "sa231016033406953045"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "asc231016033406953045"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

data "azurerm_client_config" "test" {
}

resource "azurerm_role_assignment" "test_queue" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_role_assignment" "test_blob" {
  scope                = azurerm_storage_account.test.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.test.object_id
}

resource "azurerm_arc_kubernetes_flux_configuration" "test" {
  name       = "acctest-fc-231016033406953045"
  cluster_id = azurerm_arc_kubernetes_cluster.test.id
  namespace  = "flux"

  blob_storage {
    container_id = azurerm_storage_container.test.id
    service_principal {
      client_id     = "ARM_CLIENT_ID"
      tenant_id     = "ARM_TENANT_ID"
      client_secret = "ARM_CLIENT_SECRET"
    }
  }

  kustomizations {
    name = "kustomization-1"
  }

  depends_on = [
    azurerm_arc_kubernetes_cluster_extension.test,
    azurerm_role_assignment.test_queue,
    azurerm_role_assignment.test_blob
  ]
}
