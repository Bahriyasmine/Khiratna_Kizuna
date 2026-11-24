# Relier le Python (Yasmine) et NestJS (Yassine) : guide pas à pas

## L'idée en une image

```
   Application Flutter
          │  appelle  http://<pc>:3000/farm/...
          ▼
   NestJS (Yassine, port 3000)  ──►  PostgreSQL (utilisateurs, parcelles, historique)
          │  appelle  http://localhost:8000/api/...
          ▼
   API Python (Yasmine, port 8000)   = les calculs + les données (pluie, sol, cultures)
```

- **Flutter n'appelle jamais le Python directement.** Il appelle NestJS.
- **NestJS appelle le Python** en HTTP et reçoit du JSON. C'est tout le lien entre les deux.
- **Chaque PC lance les DEUX** (Python et NestJS). Comme ça, on ne dépend pas du Wi-Fi de la salle.

---

## 1. Le dépôt Git (une seule fois)

Organisation du dépôt (voir aussi le `README.md` à la racine) :

```
<repo>/
├── ai-service/           Yasmine : Python, IA, données, API (port 8000)
├── backend/              Yassine : NestJS + PostgreSQL (port 3000)
├── mobile/               Yassine : Flutter
├── design/               Akram : maquettes, logo, couleurs
├── integration/          ce guide + les 3 fichiers NestJS prêts à copier
└── docs/                 Services_Evaluation.pdf
```

**Branches :** `main` (la version de la démo, personne ne pousse directement dessus), `yasmine`, `yassine`, `akram`.
Chacun travaille dans **son** dossier, sur **sa** branche : presque jamais de conflit.

**Yasmine** crée le dépôt sur GitHub (vide, sans README), puis depuis le dossier du projet :

```bash
git init
git status                      # vérifier que ai-service/.env N'APPARAÎT PAS
git add .
git commit -m "AI service: 6 services + Khiratna chatbot"
git branch -M main
git remote add origin https://github.com/<compte>/<repo>.git
git push -u origin main
git checkout -b yasmine && git push -u origin yasmine
```

Si le push échoue à cause du certificat SSL sur ce PC : `git -c http.sslBackend=schannel push -u origin main`.

**Yassine** (et pareil pour Akram avec `akram`) :

```bash
git clone https://github.com/<compte>/<repo>.git
cd <repo>
git checkout -b yassine
# créer le projet NestJS dans backend/ et Flutter dans mobile/
git add backend mobile
git commit -m "NestJS backend + Flutter app"
git push -u origin yassine
```

**Chaque jour :**
1. `git pull origin main` dans sa branche (récupérer le travail des autres).
2. Travailler, `git add`, `git commit`, `git push`.
3. Quand c'est prêt : sur GitHub, **Pull Request** de sa branche vers `main`, un coéquipier regarde puis **Merge**.

Les données (CSV, GeoJSON, base du chatbot, environ 60 Mo) sont **dans le dépôt**. Yassine n'a rien à recalculer.
Seul `ai-service/.env` (les clés Gemini) n'y est pas : Yasmine l'envoie en privé.

---

## 2. Lancer le Python sur le PC de Yassine (5 minutes)

1. Installer **Python 3.10 ou plus récent** depuis https://www.python.org. Pendant l'installation, cocher **« Add Python to PATH »**.
2. Dans le dossier `ai-service/`, **double-cliquer sur `start_api.bat`**. Il installe les bibliothèques la première fois, puis démarre l'API.
3. Ouvrir **http://localhost:8000/docs**. Si la liste des endpoints s'affiche, ça marche ✅.
4. Laisser cette fenêtre **ouverte** pendant qu'on travaille.

Les pages de test sont aussi disponibles : http://localhost:8000 (pluie), /soil-map (carte), /crops (cultures), /market (marché), /chat (Khiratna).

---

## 3. Brancher NestJS (Yassine)

### a) Installer
```bash
cd backend
npm i @nestjs/axios axios @nestjs/config
npm i -D @types/multer        # pour la route vocale /farm/stt
```

### b) Copier les 3 fichiers prêts
Copier les fichiers de `integration/nestjs/` dans `backend/src/python-api/` :

| Fichier | Rôle |
|---|---|
| `python-api.service.ts` | Appelle l'API Python (une méthode par endpoint) |
| `farm.controller.ts` | Les routes que Flutter appelle (`/farm/...`) |
| `python-api.module.ts` | Réunit les deux |

### c) Les ajouter dans `app.module.ts`
```ts
import { ConfigModule } from '@nestjs/config';
import { PythonApiModule } from './python-api/python-api.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PythonApiModule,
    // ... les autres modules de Yassine (TypeORM / PostgreSQL, auth...)
  ],
})
export class AppModule {}
```

### d) Le fichier `backend/.env`
```
PYTHON_API_URL=http://localhost:8000
```

### e) Tester
Lancer NestJS (`npm run start:dev`), puis ouvrir **http://localhost:3000/farm/health**. La réponse attendue est `{"status":"ok"}` ✅.

---

## 4. Les routes pour Flutter

| Service | Route NestJS (pour Flutter) | Appelle en Python | Écran |
|---|---|---|---|
| — | `GET /farm/health` | `/api/health` | Test |
| **1. Pluie → eau** | `GET /farm/rainfall/options` | `/api/rainfall/options` | Listes déroulantes (régions, cultures) |
| **1. Pluie → eau** | `GET /farm/water?region=Kasserine&crop=potato&start=2026-02&end=2026-06` | `/api/rainfall/forecast` | Graphique pluie / besoin / eau à ajouter |
| **2. Carte du sol** | `GET /farm/soil/options` | `/api/soil/options` | Variables du sol + régions |
| **2. Carte du sol** | `GET /farm/soil/map` | `/api/soil/map` | Carte du sol (GeoJSON → `flutter_map`) |
| **2. Carte du sol** | `GET /farm/soil/borders` | `/api/soil/borders` | Frontières des gouvernorats (GeoJSON) |
| **2. Carte du sol** | `GET /farm/soil/region?name=Kairouan` | `/api/soil/region` | Fiche du sol d'un gouvernorat |
| **3. Cultures adaptées** | `GET /farm/crops?N=90&P=42&K=43&temperature=21&humidity=82&ph=6.5&rainfall=203` | `/api/crops/predict` | Liste des cultures classées |
| **3. Cultures adaptées** | `GET /farm/crops/model` | `/api/crops/model` | Précision + plages des champs |
| **4. Marché** | `GET /farm/market?region=Kairouan&month=3` | `/api/market/overview` | Ce qui va manquer + ce qui rapporte |
| **4. Marché** | `GET /farm/market/history?product=wheat` | `/api/market/history` | Graphique d'un produit 2000-2027 |
| **4. Marché** | `GET /farm/market/backtest` | `/api/market/backtest` | Erreur du modèle de prévision |

Pour voir le JSON exact renvoyé par chaque route : http://localhost:8000/docs → « Try it out ».

Pour générer les types TypeScript automatiquement :
```bash
npx openapi-typescript http://localhost:8000/openapi.json -o src/python-api/python-api.types.ts
```

---

## 5. Ce que fait PostgreSQL (Yassine)

Le Python garde les **données scientifiques** et fait **tous les calculs**. PostgreSQL garde seulement les **données des agriculteurs** :
- **Utilisateurs**
- **Parcelles :** gouvernorat, culture, mois de plantation, test de sol (ECe, pH)
- **Historique :** les résultats déjà demandés, pour l'écran « mes dernières prévisions »

Exemple : quand un agriculteur ouvre sa parcelle, NestJS lit la parcelle dans PostgreSQL, puis appelle `pythonApi.waterForecast(parcelle.region, parcelle.crop, ...)` et renvoie le résultat à Flutter.

---

## 6. Règles pour travailler à deux

1. **Le contrat est le JSON.** Si Yasmine renomme un champ (par exemple `water_to_add_mm`), elle doit prévenir Yassine.
2. **Après chaque `git pull` qui modifie `ai-service/`,** relancer `start_api.bat`.
3. **Un nouvel endpoint Python** demande d'ajouter une méthode dans `python-api.service.ts` et une route dans `farm.controller.ts`.

---

## 7. Problèmes fréquents

| Message | Cause | Solution |
|---|---|---|
| `503 Python API not reachable` | Le Python n'est pas lancé | Double-cliquer sur `ai-service/start_api.bat` |
| `400` avec un message (par exemple « Unknown region ») | Mauvaise valeur envoyée | Lire le message ; les valeurs valides sont dans `/farm/rainfall/options` |
| `'python' n'est pas reconnu` | Python n'est pas dans le PATH | Réinstaller Python en cochant « Add Python to PATH » |
| `address already in use` (port 8000) | Une API Python tourne déjà | Fermer l'autre fenêtre, ou redémarrer le PC |
| Flutter (téléphone) ne joint pas NestJS | `localhost` sur le téléphone = le téléphone lui-même | Dans Flutter, utiliser l'IP du PC (par exemple `http://192.168.1.20:3000`). Sur l'émulateur Android : `http://10.0.2.2:3000` |

---

## 8. Le jour de la démo

Tout tourne sur **un seul PC** : le Python (`start_api.bat`), NestJS et Flutter. C'est le plus sûr.

**En secours (2 PC sur le même Wi-Fi)**, si le Python doit tourner sur le PC de Yasmine :
1. `start_api.bat` écoute déjà le réseau (`--host 0.0.0.0`). Windows demande d'autoriser le pare-feu : accepter.
2. Yasmine trouve son IP avec `ipconfig` (ligne « Adresse IPv4 », par exemple `192.168.1.20`).
3. Yassine met dans son `.env` : `PYTHON_API_URL=http://192.168.1.20:8000`.

⚠️ Le Wi-Fi des hackathons bloque souvent les connexions entre PC. C'est pourquoi la méthode de la partie 2 (chacun lance le Python chez lui) reste la meilleure.

---

## 9. Le chatbot Khiratna dans NestJS + Flutter

**Route :** `POST /farm/chat` (NestJS) → `POST /api/chat` (Python). Corps : `{ "question": "Can I plant potatoes after tomatoes?" }`

**Réponse (1 à 5 secondes) :**
```json
{ "answer": "No, you should not plant potatoes after tomatoes...",
  "sources": [{ "source": "crop_rotation_rules.md", "page": 5, "topic": "rotation" }],
  "retriever": "e5 dense",
  "calculator": [] }
```
Flutter affiche seulement `answer` (en anglais, phrases courtes). `sources` sert au jury si on veut le montrer.

**Ce dont le PC de Yassine a besoin (pas de GPU, pas de Docker) :**
1. Le dossier `ai-service/` avec `services/chatbot/output/chunks.json` et `services/chatbot/output/vectors_e5.npz` (la base de connaissances déjà calculée).
2. `ai-service/.env` avec `GEMINI_API_KEYS=...`. Yasmine l'envoie en privé, **jamais dans Git**.
3. `pip install -r requirements.txt`, puis Internet au **premier** lancement : le modèle E5 (~470 Mo) se télécharge une seule fois.

**La voix dans Flutter :**
- micro → texte : enregistrer la voix (package `record`), puis `POST /farm/stt` en multipart, champ `audio` → `{ "text": "..." }`.
  C'est Whisper (modèle `small`, sur le serveur Python, anglais, ~2 s, gratuit). Il connaît les 24 gouvernorats.
- texte → voix : package `flutter_tts`, `setLanguage('en-US')`
- Le flux : 🎤 → `POST /farm/stt` → `text` → `POST /farm/chat` → `answer` → `flutter_tts.speak(answer)`
- Au premier lancement, le Python télécharge aussi Whisper small (~480 Mo), une seule fois.
