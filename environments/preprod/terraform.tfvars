project     = "axion"
environment = "preprod"
region_code = "cin"
location    = "East US 2"

tags = {
  project     = "axion"
  environment = "preprod"
  managed_by  = "terraform"
}

vnet_address_space = ["10.0.0.0/16"]

subnet_prefixes = {
  frontend = ["10.0.1.0/24"]
  backend  = ["10.0.2.0/24"]
  database = ["10.0.3.0/24"]
}

# Replace with your actual admin IP before applying (used for SSH access to the frontend NSG)
allowed_ssh_source = "0.0.0.0/0"

vm_size        = "Standard_F1alds_v7"
admin_username = "azureadmin"

ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDUB0GfIxnLEnNHEqKzCtSPSF+NP33vavm31MjJ/hd+CTltSkwQi9D2G/FMM7gSnOiCOg5908858FgX21leF/bLaVJLcJB7RIhJs7CgveInibg6U9Xhckc2bpeD/57tKbnR21tWQhoQ88cV8YkPw9coj1hsC2hA+Ii/fUmE4WFOi4a//sbpTZWijM3zeZvv8wIYSR8FtXryDzcHoueagwCiErVKxRtuaQN2ZerEUCPgn9dxHIUCd2s0mOMe6TNa982Fc4T8HEy+NLPuPo77cfh4SdBP+ezUFg8XSSNRYqtDSTAzGzjNrx/wgDhBXSWIN7+YD1dOiXzpyTXG4F0Z2QYFN6Q3ZbrUZLM+0TbZFYi6BvWjDB8PiXlMUyfnC0OAU1lSWpuLxY5kW6dM2KZqMRe+1/Ij+0IEzEkV+Uz+7c5fqHwwyd4FUOYyI3zuHMGah4JjVhpMtEySBFkvoC0hQh2e7f7OguYobnmHkScR5joip6MF2I9GcOdcSFqNmAE2WQ6skhEyaBp+DOpIRFvwCC/HdrhBuEcUw0ySCy1baFyyKFwnZgZiLqGEcokBFXijhO0TrterMBjblcCUKuBceECxF2jvozHg921RD6kc2IxJhRa6k5/RyeyRybzOMhm3Uema2+OE9i5LUK9Ae7Ik7S94Fx6sOBOZn5mo0MBbgUQfvQ== adesh@Adesh-PC"
