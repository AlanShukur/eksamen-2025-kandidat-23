# README_SVAR.md

## Oppgave 1 – Terraform, S3 og Infrastruktur som kode

### **Leveranser**

* **Terraform-kode** ligger i mappen `infra-s3/`:

  * `main.tf`
  * `versions.tf`
  * `variables.tf`
  * `outputs.tf`
  * `README.md`

* **GitHub Actions workflow:**

  * `.github/workflows/terraform-s3.yml`

* **Backend:** Terraform-state lagres i S3-bucket `pgr301-terraform-state` under nøkkel `kandidat-23/infra-s3/terraform.tfstate`.

* **Bucket opprettet:**

  * Navn: `kandidat-23-data`
  * Region: `eu-west-1`

* **Lifecycle-regel:**

  * Gjelder kun filer med prefix `midlertidig/`
  * Flyttes til `GLACIER` etter valgt antall dager (standard: 30)
  * Sletting etter valgt antall dager (standard: 90)

* **Pipeline-run:**

  * `https://github.com/AlanShukur/eksamen-2025-kandidat-23/actions/runs/19478591725`

### **Drøfting – Oppgave 1**

**Hvorfor Infrastruktur som kode (IaC) med Terraform?**
Terraform gir en deklarativ måte å definere infrastruktur på. I stedet for å klikke ressurser opp i AWS Console, beskriver man hele infrastrukturen i kode. Det gjør oppsettet repeterbart, versjonskontrollert og mulig å automatisere — essensielle DevOps-prinsipper.

**Hvorfor bruke en S3-backend for Terraform state?**
Fordeler:

* Delt state mellom teammedlemmer
* Låsing av state
* State er ikke lagret lokalt, redusert risiko for tap

Dette gjør infrastrukturen sikrere og enklere å dele på tvers av utviklere.

**Lifecycle-regler – hvorfor?**
Lifecycle-styring i S3 reduserer kostnader og opprettholder orden:

* Midlertidige analyseresultater trenger kun kort levetid
* Permanente filer må ikke slettes
* Billigere lagringsklasse reduserer lagringskostnader

Dette følger "cost-optimization"-prinsippet innen AWS Well-Architected Framework.

---

## Oppgave 2 – *(Fylles ut etter du jobber med oppgave 2)*

### Leveranser

*

### Drøfting

*

---

## Oppgave 3 – *(Fylles ut senere)*

### Leveranser

*

### Drøfting

*

---

## Oppgave 4 – *(Fylles ut senere)*

### Leveranser

*

### Drøfting

*

---

