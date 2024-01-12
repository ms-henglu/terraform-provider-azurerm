


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "acctestRG-storage-240112225347341711"
  location = "West Europe"
}

resource "azurerm_virtual_network" "test" {
  name                = "acctest-VN-240112225347341711"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "acctestsub-240112225347341711"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "test" {
  name                = "acctestnic-240112225347341711"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}


# Following script will setup a LDAP server with following settings:
# - base dn: "dc=example,dc=com"
# - admin dn: "cn=admin,dc=example,dc=com"
# - admin password: "123"
# - server cert url: http://<ip>:8000/server.crt
locals {
  custom_data = <<CUSTOMDATA
#!/bin/bash

sudo -i

hostnamectl set-hostname ldap.example.com

# Install (without specifying the root pw as we are in noninteractive mode)
DEBIAN_FRONTEND=noninteractive apt install -y slapd ldap-utils

# Update the root pw to "123"
cat << EOF > /tmp/rpw.ldif
dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $(slappasswd -s 123)
EOF

ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /tmp/rpw.ldif

# Setup self signed certificate
cp /etc/ssl/certs/ca-certificates.crt /etc/ldap/sasl2
cd /etc/ldap/sasl2
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=CN/ST=SH/L=SH/O=NA/CN=${azurerm_network_interface.test.private_ip_address}" -keyout server.key -out server.crt
chown openldap. /etc/ldap/sasl2/*

cat << EOF > /tmp/cert.ldif
dn: cn=config
changetype: modify
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ldap/sasl2/ca-certificates.crt
-
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/sasl2/server.crt
-
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/sasl2/server.key
EOF

ldapmodify -Q -Y EXTERNAL -H ldapi:/// -f /tmp/cert.ldif

# Host the certificate file
[[ ! -d cert ]] && mkdir /cert
cd /cert
cp /etc/ldap/sasl2/server.crt .
nohup python3 -m http.server 8000 &

CUSTOMDATA
}

resource "azurerm_linux_virtual_machine" "test" {
  name                            = "acctest-vm-240112225347341711"
  resource_group_name             = azurerm_resource_group.test.name
  location                        = azurerm_resource_group.test.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "P@$$w0rd1234!"
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
  custom_data = base64encode(local.custom_data)
}


resource "azurerm_hpc_cache" "test" {
  name                = "acctest-HPC-240112225347341711"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  cache_size_in_gb    = 3072
  subnet_id           = azurerm_subnet.test.id
  sku_name            = "Standard_2G"

  depends_on = [azurerm_linux_virtual_machine.test]
}
