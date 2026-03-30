# 📨 Template Email Personalizzati

Questa guida spiega come creare template HTML personalizzati per le email
di sistema di PocketBase (verifica account, reset password, cambio email, OTP).

---

## 📁 Struttura

I template vanno posizionati nella cartella `pb_templates/` e montati nel
container tramite volume:

```arduino
pb_templates/
├── verification.html       # Email di verifica account
├── reset-password.html     # Email di reset password
├── confirm-email.html      # Email di conferma cambio email
└── otp.html                # Email OTP
```

Nel `compose.yaml` aggiungi il volume:

```yaml
volumes:
  - ./pb_data:/pb_data
  - ./pb_templates:/pb_templates
```

E nel file `.env` configura i path:

```bash
PB_TPL_VERIFICATION_BODY=/pb_templates/verification.html
PB_TPL_RESET_PWD_BODY=/pb_templates/reset-password.html
PB_TPL_CONFIRM_EMAIL_BODY=/pb_templates/confirm-email.html
PB_TPL_OTP_BODY=/pb_templates/otp.html
```

---

## 🔧 Variabili disponibili

PocketBase mette a disposizione le seguenti variabili nei template email:

| Variabile      | Descrizione                                        |
| -------------- | -------------------------------------------------- |
| `{APP_NAME}`   | Nome dell'applicazione (`PB_APP_NAME`)             |
| `{APP_URL}`    | URL pubblico dell'applicazione (`PB_APP_URL`)      |
| `{TOKEN}`      | Token grezzo (usa `{ACTION_URL}` quando possibile) |
| `{ACTION_URL}` | URL completo dell'azione (verifica, reset, ecc.)   |

> ⚠️ Usa sempre `{ACTION_URL}` invece di costruire manualmente l'URL con `{TOKEN}` —
> è più sicuro e resistente ai cambiamenti futuri dell'API di PocketBase.

---

## 📝 Esempio — Template di verifica account

```html
<!DOCTYPE html>
<html lang="it">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Verifica il tuo account</title>
    <style>
      body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f4;
        margin: 0;
        padding: 0;
      }
      .container {
        max-width: 600px;
        margin: 40px auto;
        background-color: #ffffff;
        border-radius: 8px;
        padding: 40px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
      }
      .button {
        display: inline-block;
        padding: 12px 24px;
        background-color: #3b82f6;
        color: #ffffff;
        text-decoration: none;
        border-radius: 6px;
        margin-top: 24px;
      }
      .footer {
        margin-top: 32px;
        font-size: 12px;
        color: #888888;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <h2>Benvenuto in {APP_NAME}!</h2>
      <p>
        Grazie per esserti registrato. Clicca sul pulsante qui sotto per
        verificare il tuo account.
      </p>
      <a href="{ACTION_URL}" class="button">Verifica il mio account</a>
      <p>Se non hai creato un account, puoi ignorare questa email.</p>
      <div class="footer">
        <p>Questo link scadrà tra 24 ore.</p>
        <p>{APP_NAME} — <a href="{APP_URL}">{APP_URL}</a></p>
      </div>
    </div>
  </body>
</html>
```

---

## ⚠️ Template e spam — cosa sapere

I client email e i provider assegnano un **punteggio di spam** (spam score) ad
ogni email in entrata. Template HTML troppo complessi possono aumentare questo
punteggio e far finire le email nella cartella spam o bloccarle del tutto.

### Fattori che aumentano lo spam score

| Fattore                                                  | Impatto  |
| -------------------------------------------------------- | -------- |
| Troppo CSS inline o complesso                            | ⬆️ Alto  |
| Immagini esterne (remote) senza testo                    | ⬆️ Alto  |
| Link shortener o URL redirect                            | ⬆️ Alto  |
| Parole chiave tipiche dello spam nel testo               | ⬆️ Alto  |
| Rapporto HTML/testo sbilanciato (tutto HTML, poco testo) | ⬆️ Medio |
| Tag HTML non standard o mal formati                      | ⬆️ Medio |
| Font e colori eccessivi                                  | ⬆️ Basso |

### Fattori che abbassano lo spam score

| Fattore                                                 | Impatto  |
| ------------------------------------------------------- | -------- |
| Template semplice con buon rapporto testo/HTML          | ⬇️ Alto  |
| Dominio mittente con SPF, DKIM e DMARC configurati      | ⬇️ Alto  |
| SMTP con provider affidabile (SendGrid, Brevo, AWS SES) | ⬇️ Alto  |
| Link diretto senza redirect                             | ⬇️ Medio |

> ⚠️ **I punteggi variano da provider a provider** — Gmail, Outlook, Yahoo e i
> provider aziendali usano algoritmi diversi e soglie diverse. Un template che
> funziona perfettamente con Gmail potrebbe finire nello spam su Outlook e viceversa.
> Non esiste una configurazione universale: testa sempre su più provider prima
> di andare in produzione.
>
> 💡 Strumenti utili per testare lo spam score del tuo template:
> [Mail Tester](https://www.mail-tester.com/) · [MXToolbox](https://mxtoolbox.com/)

---

## 💡 Consigli

- Testa sempre i template inviando un'email di prova dalla dashboard di PocketBase
  → **Dashboard > Settings > Mail Settings > Send test email**
- Mantieni il design semplice — non tutti i client email supportano CSS avanzato
- Includi sempre una versione testuale del contenuto per accessibilità
- Verifica la resa su client email comuni (Gmail, Outlook, Apple Mail)

---

## 📚 Risorse utili

- [Documentazione ufficiale PocketBase — Email Templates](https://pocketbase.io/docs/going-to-production/#smtp-settings)
- [Can I Email — compatibilità CSS nei client email](https://www.caniemail.com/)
