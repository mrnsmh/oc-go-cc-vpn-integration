# oc-go-cc VPN Integration

Wrapper pour `oc-go-cc` permettant de gérer le VPN et les providers pour bypasser les restrictions de taux (rate limiting) d'OpenCode Zen.

## Fonctionnalités

- **Démarrage automatique** : Lance le VPN et le proxy `oc-go-cc` en une commande.
- **Switch Provider** : Change dynamiquement entre `zen` et `go` (ou URL custom) pour contourner les limits.
- **Intégration VPN** : Utilise le script `vpn` pour gérer le conteneur Docker.
- **Logging** : Journalisation dans `/tmp/oc-vpn.log`.

## Prérequis

- `oc-go-cc` installé et configuré (`~/.config/oc-go-cc/config.json`).
- Script `vpn` installé (`/usr/local/bin/vpn`).
- `jq` (optionnel, pour la mise à jour automatique de la config).

## Installation

1. Cloner ce dépôt :
   ```bash
   git clone https://github.com/<votre-user>/oc-go-cc-vpn-integration.git
   cd oc-go-cc-vpn-integration
   ```

2. Rendre le script exécutable :
   ```bash
   chmod +x oc-vpn.sh
   ```

3. (Optionnel) Installer en tant que commande globale :
   ```bash
   sudo cp oc-vpn.sh /usr/local/bin/oc-vpn
   ```

## Utilisation

| Commande | Description |
|----------|-------------|
| `./oc-vpn.sh start new-york` | Démarre le VPN (New York) puis le proxy |
| `./oc-vpn.sh switch go` | Change le provider vers OpenCode Go |
| `./oc-vpn.sh switch custom` | Demande une URL personnalisée |
| `./oc-vpn.sh status` | Affiche l'état VPN et la config proxy |
| `./oc-vpn.sh stop` | Arrête le VPN |

## Stratégie Bypass Rate Limit

1. **Démarrer avec Zen** : `./oc-vpn.sh start <location>`
2. **Si Rate Limit atteint** : 
   - `./oc-vpn.sh switch go` (utilise le pool de tokens Go)
   - Ou `./oc-vpn.sh switch custom` avec une URL proxy alternative.
3. **Changer d'IP** (optionnel) :
   - `vpn change <nouveau-lieu>` change l'adresse IP du conteneur VPN.

## Fichiers

```
oc-go-cc-vpn-integration/
├── oc-vpn.sh          # Script principal
├── README.md
└── .gitignore
```
