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

## Oppgave 2 (Del A og B) – 

### Leveranser
- **API Gateway URL:** `https://fmgb0cwb3f.execute-api.eu-west-1.amazonaws.com/Prod/analyze/`
- **S3 objekt med analysemal/svar:** `s3://kandidat-23-data/midlertidig/comprehend-20251118-222810-2718ec4f.json`
- **Workflow-fil:** `.github/workflows/sam-deploy.yml`
- **Workflow-kjøring (deploy til AWS):**
  - `https://github.com/AlanShukur/eksamen-2025-kandidat-23/actions/runs/19483032186/job/55758894048`
- **Workflow-kjøring (PR-validering uten deploy):**
  - `https://github.com/AlanShukur/eksamen-2025-kandidat-23/pull/2`

### Drøfting – Oppgave 2

**Hvorfor lagre resultatene i S3?**

Å lagre analyseresultater i S3 gjør løsningen mer robust og sporbar enn å kun returnere svaret direkte fra Lambda:
- Man kan senere gjøre batch-analyser, reanalyse, eller koble på andre systemer (for eksempel dataplattform eller BI-verktøy).
- S3 fungerer som et sentralt, billig og svært skalerbart lager for analyseresultater.
- Ved å legge resultatene under `midlertidig/` utnytter vi lifecycle-regelen fra Oppgave 1 for automatisk opprydding og kostnadskontroll.

**Hvorfor bruke SAM for Lambda-applikasjonen?**

AWS SAM gir en enklere og mer deklarativ måte å beskrive serverless-applikasjoner på:
- `template.yaml` beskriver Lambda, API Gateway, IAM-roller og parameterverdier.
- `sam build` pakker koden riktig (inkludert avhengigheter) og gjør deploy forutsigbar.
- `sam local invoke` og `sam local start-api` gjør det mulig å teste funksjonen lokalt før deploy.
Dette gir bedre utvikleropplevelse og passer godt inn i DevOps-prinsipper om hyppig feedback og automatisering.

**Hvorfor skal vi *ikke* deploye på hver pull request?**

Å deploye til produksjonsmiljø (eller delt AWS-miljø) på hver PR er dårlig praksis fordi:
- PR-er er ofte uferdige eller under review – koden er ikke godkjent enda.
- Det kan skape «støy» og ustabilitet i miljøet hvis mange PR-er deployer parallelt.
- Kostnader og ressursbruk i AWS øker unødvendig.

En bedre praksis, som vi implementerer her, er:
- På PR: kun kjøre **validering og bygg** (`sam validate`, `sam build`). Dette sikrer at endringer er syntaktisk riktige og byggbare.
- På push til `main`: kjøre full **deploy**. Da vet vi at koden er reviewet og godkjent.

**DevOps-perspektiv på workflowen**

Workflowen for Oppgave 2 følger DevOps-prinsipper på flere måter:
- **Automatisering:** Hele bygg- og deployprosessen er automatisert via GitHub Actions.
- **Kontinuerlig integrasjon:** Hver PR blir automatisk validert og bygget, noe som gir rask feedback til utviklere.
- **Kontinuerlig leveranse:** Endringer på `main` deployes automatisk til AWS, uten manuelle steg.
- **Konfigurasjon via kode:** Både `template.yaml` (SAM) og workflow-fila er kode, som kan versjonskontrolleres, reviewes og rulles tilbake ved behov.

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

