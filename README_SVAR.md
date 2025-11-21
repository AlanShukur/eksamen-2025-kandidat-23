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

## Instruksjoner til sensor

### For å kjøre workflowen i egen GitHub-konto må sensor:

1. **Forke repoet eller kopiere det til egen GitHub-bruker.**  

2. **Opprette GitHub Secrets under Settings → Secrets → Actions:**  
   I sensor sitt repo må disse settes i GitHub → Settings → Secrets → Actions:
   ```
   AWS_ACCESS_KEY_ID
   AWS_SECRET_ACCESS_KEY
   ```
  
3. **Bruke en IAM-bruker med tilgang til CloudFormation, Lambda, API Gateway og S3.**  

4. **Sørge for at region er eu-west-1.**  

5. **Lage en Pull Request med endring i sam-comprehend/ for å teste validering uten deploy.**  

6. **Merge PR-en eller push til main for å teste full deploy-pipeline.**  

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

## Oppgave 3 – Docker + Docker Hub CI/CD

### Hvordan sensor kan verifisere løsningen

1. **Fork prosjektet**

2. **Legg inn Docker Hub secrets i fork-en**
   I sensor sitt repo må disse settes i GitHub → Settings → Secrets → Actions:
   ```
   DOCKERHUB_USERNAME
   DOCKERHUB_TOKEN
   ```

3. **Trigger workflow**
   Sensor gjør en commit til `main` eller merger PR.

4. **Workflow vil:**
   - bygge Docker-image basert på `sentiment-docker/Dockerfile`
   - tagge imaget `<username>/sentiment-docker:latest`
   - pushe til Docker Hub

5. **Verifiser at image er publisert**
   Sensor kan sjekke:
   ```
   https://hub.docker.com/r/<DOCKERHUB_USERNAME>/sentiment-docker
   ```

6. **Teste containeren**
   Sensor kan kjøre containeren lokalt:

   ```bash
   docker run -p 8080:8080 <username>/sentiment-docker:latest
   ```

   Test API-et:

   ```bash
   curl -X POST http://localhost:8080/api/analyze \
     -H "Content-Type: application/json" \
     -d '{"requestId": "test", "text": "NVIDIA is strong"}'
   ```

   Responsen viser at Bedrock-integrasjon og logikk fungerer.

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

---

## Oppgave 4 (Del B) – Observabilitet med Terraform (Dashboard + Alarm + SNS)

### **Leveranser**

#### **Terraform-kode (infra-cloudwatch/)**
Følgende filer ligger i `infra-cloudwatch/`:

- `main.tf`
- `variables.tf`
- `outputs.tf`
- `versions.tf`

Terraform-modulen oppretter:
- CloudWatch Dashboard  
- CloudWatch Alarm  
- SNS Topic  
- SNS E-postabonnement  

---

### **CloudWatch Dashboard**

Dashboard-navn:  
**`kandidat-23-sentiment-dashboard`**

Dashboardet viser:
- **bedrock.api.latency** (Timer-metrikk)
- **sentiment.detected_companies.gauge** (Gauge-metrikk)

Skjermbilde:
![Dashboard](screenshots/cloudwatch-dashboard.png)

---

### **CloudWatch Alarm**

Alarm opprettet via Terraform:

- **Navn:** `kandidat23-bedrock-latency-high`
- **Metric:** `bedrock.api.latency`
- **Namespace:** `kandidat-23-sentimentapp`
- **Alarmtype:** *Missing data / No latency alarm*
- **Status:** Verifisert i ALARM state

Skjermbilder:
![Alarm Overview & Triggered](screenshots/alarm-overview.png)

---

### **SNS Varsling**

Terraform opprettet:
- `aws_sns_topic.alarm_topic`
- `aws_sns_topic_subscription.email_sub`

E-post ble mottatt og bekreftet.

Skjermbilde:
![SNS Email](screenshots/sns-alarm.png)

---

### **Alarm Trigger Test**

Alarmen ble trigget ved å stoppe innsending av latensdata (ingen datapunkter → ALARM).

---

## **Drøfting – Oppgave 4 Del B**

**Hvorfor CloudWatch Dashboard?**  
Dashboardet samler kritiske applikasjonsmetrikker på ett sted og gir rask oversikt over systemets tilstand. Det gjør det enklere å se trender, oppdage avvik og ta beslutninger basert på faktiske målinger, noe som er sentralt i DevOps-prinsippet “kontinuerlig feedback”.

**Hvorfor en alarm på manglende latensdata?**  
Manglende metrikker er ofte like kritisk som dårlig ytelse. Når applikasjonen slutter å sende data, kan det bety:
- container krasj
- nettverksproblemer
- feil i credentials
- feil i Micrometer-integrasjonen

Alarmen gir tidlig varsling slik at feilen kan oppdages før brukere merker det.

**Hvorfor SNS for varsling?**  
SNS er en enkel, pålitelig og standardisert tjeneste for alerting i AWS. E-post er nok i dette prosjektet, men samme infrastruktur kan senere kobles til Slack, PagerDuty eller SMS uten endringer i Terraform-koden.

**DevOps-perspektiv**  
Oppgave 4 Del B demonstrerer flere DevOps-prinsipper:
- **Automatisering:** Dashboard og alarmer bygges gjennom IaC, ikke manuelt.
- **Observabilitet:** Metrikker, logging og alarmer gir full innsikt i systemets tilstand.
- **Feedback loops:** Når alarm utløses og e-post sendes, får teamet umiddelbar tilbakemelding.
- **Pålitelighet:** Overvåkningsinfrastruktur gjør systemet mer robust og mindre sårbart.

---

## Oppgave 5 – KI-assistert Systemutvikling og DevOps-prinsipper

### **Innledning**

Bruken av KI-assistenter som GitHub Copilot, ChatGPT og Claude har endret måten utviklere skriver kode på. Disse verktøyene kan generere funksjoner, lage dokumentasjon, skrive tester og foreslå forbedringer. Dette gir et potensial for økt hastighet og produktivitet i utviklingsprosesser. Samtidig introduserer KI nye typer risiko knyttet til kvalitet, sikkerhet og vedlikehold. I denne drøftingen analyserer jeg hvordan KI-assistert utvikling påvirker de tre sentrale DevOps-prinsippene: **flyt**, **feedback** og **kontinuerlig læring og forbedring**.

---

## **Flyt (Flow)**

KI-verktøy kan i stor grad forbedre flyten i utviklingsprosessen. For det første kan KI generere boilerplate-kode, forslag til funksjoner og dokumentasjon langt raskere enn en utvikler kan gjøre manuelt. Dette reduserer tiden fra idé til første fungerende prototype. I eksamen har det for eksempel vært naturlig å bruke KI til å fikse feil i Terraform-konfigurasjoner, forstå API-feilmeldinger eller generere testdata. Dette eliminerer flaskehalser som vanligvis oppstår når utviklere bruker tid på å søke etter feil eller skrive repetitive deler av koden.

Samtidig finnes det risiko. KI kan introdusere nye flaskehalser hvis utviklere blir for avhengige av forslag som ikke passer systemets arkitektur eller krav. KI kan foreslå løsninger som ser riktige ut, men som skjuler ineffektivitet, sikkerhetshull eller ikke følger etablerte praksiser. Dette betyr at code review kan bli mer krevende, fordi teamet må bruke tid på å verifisere at forslagene ikke bare fungerer, men også er riktige, sikre og vedlikeholdbare.

I DevOps-sammenheng kan også deployment-syklusen påvirkes. KI-generert kode som passerer gjennom pipelines uten tilstrekkelig verifikasjon kan føre til hyppigere feil i produksjon. Flow forbedres altså kun hvis det etableres gode mekanismer for kvalitetssikring. KI kan fjerne manuelle flaskehalser, men kan samtidig introdusere nye i form av økt behov for kontroll.

---

## **Feedback**

Feedback er en kjerne i DevOps og KI endrer hvordan feedback-looper fungerer. På den positive siden kan KI generere tester, hjelpe med å lese logg-utskrifter og foreslå forbedringer basert på systematisk mønstergjenkjenning i kodebasen. Når automatiske pipelines kjører tester, finner feil og rapporterer tilbake til utvikleren, kan KI brukes til å forklare hvorfor noe feiler og foreslå konkrete rettelser.

I systemer hvor KI genererer kode, blir observabilitet og monitorering enda viktigere. Feil kan oppstå på grunn av misforståtte instruksjoner, unøyaktigheter i modellens kunnskap eller kode som virker, men som ikke gjør riktig ting. Derfor må team sikre at automatiserte tester, statiske analyser og CloudWatch-metrikker gir tydelig og kontinuerlig feedback.

Et eksempel fra eksamen er integrasjonen mot AWS Bedrock. Hvis KI hadde skrevet store deler av controller- eller metrics-koden, ville det vært nødvendig å bruke CloudWatch-metrikker, API-feilmeldinger og lokal testing til å verifisere at alt virker riktig. KI kan ikke selv forstå driftssituasjonen det må DevOps-praksisen kompensere for gjennom gode overvåkingsmekanismer.

Et potensielt problem er at utviklere kan stole for mye på KI-forslag og dermed overse viktige signaler i feedback-systemet. Hvis KI brukes uten kritisk vurdering, kan feil som burde vært oppdaget tidlig slippe gjennom. Derfor må KI-assistert utvikling kombineres med robuste pipelines, tydelige alarmgrenser og regelmessig gjennomgang av produksjonsdata.

---

## **Kontinuerlig læring og forbedring**

KI påvirker læring på to måter. På den positive siden fungerer KI som en mentor. Den kan forklare konsepter, foreslå korrekt kode og hjelpe utviklere med å lære nye teknologier raskere. I denne eksamenen kunne KI hjelpe med å forstå hvordan man setter opp Terraform-moduler, SAM-deploy eller hvordan man konfigurerer CloudWatch-metrikker.

Men den største risikoen er at utviklere kan miste dybdeforståelse hvis de lar KI gjøre for mye arbeid. DevOps krever at utviklere forstår hele pipeline-løpet fra infrastruktur til drift. Hvis KI genererer kode som utviklere ikke forstår, svekkes evnen til feilsøking og problemløsning. Over tid kan dette føre til redusert kompetanse i teamet.

Konsekvensen er at organisasjoner må etablere prinsipper for *ansvarlig KI-bruk*. Dette innebærer blant annet:
- kontinuerlig code review av mennesker  
- krav om dokumentasjon av KI-genererte endringer  
- retrospektiver som analyserer hvor KI ble brukt  
- fokus på å lære hvorfor løsninger fungerer, ikke bare akseptere dem  

I tillegg må utviklere lære nye ferdigheter: prompt engineering, verifikasjon av KI-generert kode og kritisk evaluering av forslag. KI erstatter ikke faglig forståelse det forsterker behovet for den.

---

## **Konklusjon**

KI-assistert utvikling kan forbedre DevOps-praksis betydelig når det gjelder flow, feedback og kontinuerlig læring, men fordelene kommer med tydelige utfordringer. KI gir økt produktivitet, raskere feilsøking og bedre utvikleropplevelse. Samtidig introduserer den risiko for feil, svakere kodekvalitet og redusert dybdekunnskap.

Effektiv bruk av KI krever derfor en balanse: KI bør være et verktøy som akselererer arbeidet, men ikke erstatte utviklerens evne til å forstå, verifisere og forbedre systemer. For team som klarer denne balansen, kan KI styrke alle tre DevOps-prinsippene og bidra til tryggere, raskere og mer læringsorientert utvikling.


