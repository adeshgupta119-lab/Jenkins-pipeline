# Enterprise Azure 3-Tier Infrastructure & Jenkins-Ansible CI/CD Pipeline 🚀

[![Terraform](https://img.shields.io/badge/Terraform-v1.9%2B-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/Microsoft_Azure-Cloud_Infra-0089D6?style=for-the-badge&logo=microsoft-azure&logoColor=white)](https://azure.microsoft.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-CI%2FCD_Automation-D24939?style=for-the-badge&logo=jenkins&logoColor=white)](https://www.jenkins.io/)
[![Ansible](https://img.shields.io/badge/Ansible-Configuration_Mgmt-EE0000?style=for-the-badge&logo=ansible&logoColor=white)](https://www.ansible.com/)
[![Security](https://img.shields.io/badge/Security-Azure_Key_Vault-0078D4?style=for-the-badge&logo=microsoft&logoColor=white)](#)

Production-grade Infrastructure as Code (IaC) and DevSecOps deployment pipeline. Automates the end-to-end provisioning of an **Azure 3-Tier Enterprise Architecture (Frontend, Backend, Database)** with **Azure Key Vault**, **Network Security Groups (NSGs)**, and dynamic **Ansible configuration management** orchestrated through a declarative **Jenkinsfile** CI/CD pipeline.

---

## 🏗️ End-to-End Pipeline & Architecture Workflow

```
  ┌──────────────┐
  │ Code Commit  │
  └──────┬───────┘
         │
         ▼
  ┌────────────────────────────────────────────────────────────────────────┐
  │                           JENKINS CI/CD PIPELINE                       │
  │  Stage 1: Checkout ➔ Stage 2: TF Init ➔ Stage 3: TF Plan               │
  │  Stage 4: [Manual Production Approval Gate]                            │
  │  Stage 5: Terraform Apply ➔ Provisions Azure 3-Tier Infra              │
  │  Stage 6: Dynamic Inventory Extraction (Outputs ➔ inventory.ini)       │
  │  Stage 7: Ansible Configuration Playbook Execution                     │
  └───────────────────────────────────┬────────────────────────────────────┘
                                      │
         ┌────────────────────────────┼────────────────────────────┐
         ▼                            ▼                            ▼
┌──────────────────┐        ┌──────────────────┐        ┌──────────────────┐
│  Frontend Tier   │        │   Backend Tier   │        │  Database Tier   │
│  Public IP + NSG │ ────➔  │  Private Subnet  │ ────➔  │  Private Subnet  │
│  Standard_B1s VM │        │  Standard_B1s VM │        │  Standard_B1s VM │
└──────────────────┘        └──────────────────┘        └──────────────────┘
         │                            │                            │
         └────────────────────────────┼────────────────────────────┘
                                      ▼
                        ┌───────────────────────────┐
                        │ Azure Key Vault & Storage │
                        │  (Automated Secret Mgmt)  │
                        └───────────────────────────┘
```

---

## 📂 Repository Directory Layout

```
├── ansible/
│   └── site.yml                 # Playbooks for VM post-provisioning configuration
├── environments/
│   ├── preprod/
│   │   ├── main.tf              # Root preprod environment orchestrator
│   │   ├── provider.tf          # Azure provider & remote state config
│   │   ├── variables.tf         # Input parameters with validations
│   │   ├── outputs.tf           # Exported VM IPs, subnets, resource IDs
│   │   └── terraform.tfvars     # Environment configurations
│   └── prod/                    # Production environment targets
├── modules/
│   ├── azurerm_resource_group/  # Resource group isolation
│   ├── azurerm_virtual_network/ # Core VNet definitions
│   ├── azurerm_subnet/          # Tiered subnets (Frontend, Backend, DB)
│   ├── azurerm_network_security_group/ # Tiered NSGs restricting SSH & ports
│   ├── azurerm_public_ip/       # Public IP allocation for Frontend
│   ├── azurerm_storage_account/ # Storage with deletion-lock protection
│   ├── azurerm_key_vault/       # Zero-trust secret management
│   └── azurerm_virtual_machine/ # Standardized compute modules
├── Jenkinsfile                  # Multi-stage CI/CD pipeline definition
└── README.md
```

---

## 🏷️ Standardized Naming Conventions

Every resource name is dynamically derived from three inputs in `terraform.tfvars` (`project`, `environment`, `region_code`) via `locals.name_prefix`, eliminating naming drift across modules:

| Resource | Pattern | Example |
| :--- | :--- | :--- |
| **Resource Group** | `rg-<prefix>` | `rg-axion-preprod-cin` |
| **VNet** | `vnet-<prefix>` | `vnet-axion-preprod-cin` |
| **Subnets** | `snet-<prefix>-<tier>` | `snet-axion-preprod-cin-frontend` |
| **NSGs** | `nsg-<prefix>-<tier>` | `nsg-axion-preprod-cin-backend` |
| **Public IP** | `pip-<prefix>-frontend` | `pip-axion-preprod-cin-frontend` |
| **NIC** | `nic-<prefix>-<tier>` | `nic-axion-preprod-cin-database` |
| **Virtual Machines** | `vm-<prefix>-<tier>` | `vm-axion-preprod-cin-frontend` |
| **Storage Account** | `st<prefix-no-hyphens><random5>` | `staxionpreprodcinab12x` |
| **Key Vault** | `kv-<prefix>-<random5>` | `kv-axion-preprod-cin-ab12x` |

---

## 🔒 Enterprise Security & Secrets Workflow

1. **Zero Hardcoded Secrets:** `random_password.vm_admin` generates cryptographic credentials dynamically at apply time.
2. **Key Vault Integration:** Automatically deposited in Azure Key Vault via the `azurerm_key_vault` module.
3. **Data Source Decoupling:** Compute modules retrieve secrets using `data.azurerm_key_vault_secret`, ensuring passwords never appear in plaintext logs.
4. **Least Privilege Isolation:** Frontend is internet-facing; Backend and Database tiers have zero public IP exposure and can only be accessed across internal VNet peering/subnets.

---

## 🚀 Usage & Deployment

### 1. Manual Local Execution
```bash
cd environments/preprod
terraform init
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
```

### 2. Jenkins Automated Pipeline
Configure credentials in Jenkins Credentials Manager:
- `azure-client-id`, `azure-secret-id`, `azure-subscription-id`, `azure-tenant-id`
- `vm-ssh-key` (SSH private key for Ansible execution)

Trigger the build via Jenkins Webhook or manual dispatch.

---

## 👤 Author
**Adesh Gupta**  
*Lead DevSecOps Engineer & Enterprise Cloud Architect*  
- GitHub: [@adeshgupta119-lab](https://github.com/adeshgupta119-lab)  
- Email: [adeshgupta119@gmail.com](mailto:adeshgupta119@gmail.com)
