# infra-s3

Terraform-konfigurasjon for S3-bucket med lifecycle-regler for analyseresultater.

## Innhold

- Oppretter en S3-bucket for analyseresultater (`kandidat-23-data`)
- Aktiverer versjonering på bucketen
- Definerer en lifecycle-strategi for midlertidige filer under `midlertidig/`:
  - Flyttes til GLACIER etter `temp_files_transition_days` (default: 30 dager)
  - Sletttes etter `temp_files_expiration_days` (default: 90 dager)

## Variabler

Se `variables.tf` for alle variabler og default-verdier.

## Kjøre lokalt

```bash
cd infra-s3

terraform init   # bruker S3-backend pgr301-terraform-state
terraform plan
terraform apply
