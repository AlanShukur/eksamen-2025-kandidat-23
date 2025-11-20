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

  * https://github.com/AlanShukur/eksamen-2025-kandidat-23/actions/runs/19478591725

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
  - https://github.com/AlanShukur/eksamen-2025-kandidat-23/actions/runs/19483032186/job/55758894048
- **Workflow-kjøring (PR-validering uten deploy):**
  - https://github.com/AlanShukur/eksamen-2025-kandidat-23/actions/runs/19483029694/job/55758885603

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

## Oppgave 3 – Docker og GitHub Actions (Del A og B)

### Leveranser

- **Dockerfile:** `sentiment-docker/Dockerfile`
- **Docker Hub image:**  
  https://hub.docker.com/r/AlanShukur/sentiment-docker
- **Workflow-fil:**  
  `.github/workflows/docker-dockerhub.yml`
- **Workflow-kjøring (push til Docker Hub):**  
  https://github.com/AlanShukur/eksamen-2025-kandidat-23/actions/runs/19509821560/job/55846308502

### Drøfting – Oppgave 3

**Hvorfor Docker?**  
Containerisering gjør applikasjonen portabel og konsistent: samme kjørbare miljø lokalt, i test og i produksjon. Ingen “works on my machine”-problemer, og applikasjonen kan kjøres på hvilken som helst host som støtter Docker.

**Hvorfor multi-stage builds?**  
Multi-stage build reduserer image-størrelse ved å skille bygg-steg og runtime-steg. Dette gir:  
- raskere deploy  
- lavere kostnader  
- mindre angrepsflate

**Hvorfor pushe til Docker Hub?**  
Docker Hub fungerer som et globalt registry der images kan hentes av GitHub Actions, utviklere, og Kubernetes/EC2/ECS.  
Workflowen automatiserer bygg–og–publiser prosessen slik at ny versjon alltid legges ut ved push til `main`.

**DevOps-prinsipp:**  
Oppgaven viser “CI/CD for containers”:  
- CI → bygge container på hver commit  
- CD → publisere artefakt til container registry  
Dette gir sporbarhet, versjonering og automatisert leveranse.

---

## Oppgave 4 – Observabilitet og Custom Metrics (Del A)

### Leveranser (Del A)
- **Micrometer-metrikker implementert i Java:**
  - Counter (`sentiment.analysis.total`)
  - Timer (`bedrock.api.latency`)
  - Gauge (`sentiment.detected_companies.gauge`)
  - Distribution Summary (`bedrock.confidence.distribution`)
- **Namespace brukt i CloudWatch:** `kandidat-23-sentimentapp`
- **Skjermbilder av metrikker i CloudWatch:**
  - Company Model
  - Company Sentiment
  - Namespace-oversikt (alle faner)
  - Phi Sentiment
  - Gauge-metrikk

---

### Skjermbilder – CloudWatch Metrics

#### **Company Model Metric**
![Company Model Metric](screenshots/company-model.png)

#### **Company Sentiment Metric**
![Company Sentiment Metric](screenshots/company-sentiment.png)

#### **Namespace Tabs (Alle metrikker under namespace)**
![Namespace Tabs](screenshots/namespace-tabs.png)

#### **Phi Sentiment Metric**
![Phi Sentiment Metric](screenshots/phi-sentiment.png)

#### **Gauge Metric – Companies Detected**
![Gauge Metric](screenshots/gauge.png)

---

### Drøfting – Oppgave 4 Del A

I denne oppgaven implementerte jeg fire typer Micrometer-metrikker i Spring Boot-applikasjonen for å gi bedre innsikt i hvordan sentimentanalysen fungerer når den kjører i praksis. Disse metrikksignalene eksporteres automatisk til Amazon CloudWatch gjennom Micrometer CloudWatch Registry, konfigurert med namespace `kandidat-23-sentimentapp`.

#### **1. Counter (sentiment.analysis.total)**
Counter brukes til å telle antall analyser som blir gjennomført. Den øker for hver forespørsel og gir en enkel, men svært nyttig KPI for trafikkvolum over tid. Siden den aldri minker, er den ideell for å vise antall hendelser.

#### **2. Timer (bedrock.api.latency)**
Timer måler hvor lang tid AWS Bedrock bruker på å svare. Dette er kritisk for observabilitet fordi:
- Du kan se gjennomsnittlig responstid
- Du får persentiler (p50, p90, p99)
- Du ser om spesifikke selskaper eller modeller skaper latensproblemer

Dette er en av de mest relevante metrikken for en API-drevet løsning.

#### **3. Gauge (sentiment.detected_companies.gauge)**
Gauge representerer en verdi som kan både øke og minke. Jeg brukte den til å måle *hvor mange selskaper som ble funnet i siste analyse*. Den gir sanntidsinnsikt i hvordan kompleks input påvirker applikasjonen.

Gauge er spesielt nyttig når verdier varierer mye mellom forespørsler.

#### **4. Distribution Summary (bedrock.confidence.distribution)**
Denne metrikktypen viser spredningen av confidence-scores for hvert sentiment. Dette gir verdifull innsikt:
- Er analysene typisk sikre (0.9–1.0)?
- Varierer de mye?
- Får enkelte selskaper lavere gjennomsnittlig score?

Dette er nyttig både for modellforståelse og kvalitetsovervåkning.

---

### Hvorfor disse metrikktype-valgene?

| Instrument | Hvorfor valgt? | Typisk bruk |
|-----------|----------------|-------------|
| **Counter** | Måle volum over tid | Trafikk, antall kall |
| **Timer** | Måle ytelse og latens | API-responstid |
| **Gauge** | Sanntidverdi som går opp og ned | Tilstander, bufferstørrelser |
| **Distribution Summary** | Fordelingsanalyse | Score, payload-størrelser |

Dette dekker fire ulike aspekter av observabilitet:
- **Bruksmønster**
- **Ytelse**
- **Systemtilstand**
- **Kvalitet på analyse**

Dermed gir det et helhetlig bilde av oppførselen til applikasjonen.

---

