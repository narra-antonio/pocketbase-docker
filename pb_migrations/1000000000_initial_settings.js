/// <reference path="../pb_data/types.d.ts" />

migrate((app) => {
    console.log('🚀 Initial settings migration running...')

    const settings = app.settings()

    // ===========================================
    // META
    // ===========================================
    settings.meta.appName = process.env.PB_APP_NAME || 'My PocketBase App'
    settings.meta.appURL = process.env.PB_APP_URL || 'http://localhost:8090'
    settings.meta.senderName = process.env.PB_SENDER_NAME || 'Support'
    settings.meta.senderAddress = process.env.PB_SENDER_ADDRESS || 'noreply@localhost'
    settings.meta.hideControls = process.env.PB_HIDE_CONTROLS === 'true'

    // ===========================================
    // SMTP
    // ===========================================
    settings.smtp.enabled = process.env.PB_SMTP_ENABLED === 'true'
    settings.smtp.host = process.env.PB_SMTP_HOST || ''
    settings.smtp.port = parseInt(process.env.PB_SMTP_PORT || '587')
    settings.smtp.username = process.env.PB_SMTP_USERNAME || ''
    settings.smtp.password = process.env.PB_SMTP_PASSWORD || ''
    settings.smtp.authMethod = process.env.PB_SMTP_AUTH_METHOD || 'PLAIN'
    settings.smtp.tls = process.env.PB_SMTP_TLS !== 'false'
    settings.smtp.localName = process.env.PB_SMTP_LOCAL_NAME || ''

    // ===========================================
    // S3 STORAGE
    // ===========================================
    settings.s3.enabled = process.env.PB_S3_ENABLED === 'true'
    settings.s3.bucket = process.env.PB_S3_BUCKET || ''
    settings.s3.region = process.env.PB_S3_REGION || ''
    settings.s3.endpoint = process.env.PB_S3_ENDPOINT || ''
    settings.s3.accessKey = process.env.PB_S3_ACCESS_KEY || ''
    settings.s3.secret = process.env.PB_S3_SECRET || ''
    settings.s3.forcePathStyle = process.env.PB_S3_FORCE_PATH_STYLE === 'true'

    // ===========================================
    // BACKUPS
    // ===========================================
    settings.backups.cron = process.env.PB_BACKUPS_CRON || '0 0 * * *'
    settings.backups.cronMaxKeep = parseInt(process.env.PB_BACKUPS_CRON_MAX_KEEP || '3')
    settings.backups.s3.enabled = process.env.PB_BACKUPS_S3_ENABLED === 'true'
    settings.backups.s3.bucket = process.env.PB_BACKUPS_S3_BUCKET || ''
    settings.backups.s3.region = process.env.PB_BACKUPS_S3_REGION || ''
    settings.backups.s3.endpoint = process.env.PB_BACKUPS_S3_ENDPOINT || ''
    settings.backups.s3.accessKey = process.env.PB_BACKUPS_S3_ACCESS_KEY || ''
    settings.backups.s3.secret = process.env.PB_BACKUPS_S3_SECRET || ''
    settings.backups.s3.forcePathStyle = process.env.PB_BACKUPS_S3_FORCE_PATH_STYLE === 'true'

    // ===========================================
    // LOGS
    // ===========================================
    settings.logs.maxDays = parseInt(process.env.PB_LOGS_MAX_DAYS || '7')
    settings.logs.minLevel = parseInt(process.env.PB_LOGS_MIN_LEVEL || '0')
    settings.logs.logIP = process.env.PB_LOGS_LOG_IP !== 'false'
    settings.logs.logAuthId = process.env.PB_LOGS_LOG_AUTH_ID !== 'false'

    // ===========================================
    // RATE LIMITING
    // ===========================================
    settings.rateLimits.enabled = process.env.PB_RATE_LIMITS_ENABLED === 'true'

    if (process.env.PB_RATE_LIMITS_RULES) {
        const rules = []
        process.env.PB_RATE_LIMITS_RULES.split(';').forEach((ruleStr) => {
            const parts = ruleStr.trim().split('|')
            if (parts.length === 4) {
                rules.push({
                    label: parts[0],
                    audience: parts[1],
                    duration: parseInt(parts[2]),
                    maxRequests: parseInt(parts[3]),
                })
            }
        })
        if (rules.length > 0) {
            settings.rateLimits.rules = rules
        }
    }

    // ===========================================
    // TRUSTED PROXY
    // ===========================================
    settings.trustedProxy.useLeftmostIP = process.env.PB_TRUSTED_PROXY_USE_LEFTMOST_IP === 'true'
    if (process.env.PB_TRUSTED_PROXY_HEADERS) {
        settings.trustedProxy.headers = process.env.PB_TRUSTED_PROXY_HEADERS.split(',').map((h) => h.trim())
    } else {
        settings.trustedProxy.headers = []
    }

    // ===========================================
    // BATCH
    // ===========================================
    settings.batch.enabled = process.env.PB_BATCH_ENABLED !== 'false'
    settings.batch.maxRequests = parseInt(process.env.PB_BATCH_MAX_REQUESTS || '100')
    settings.batch.timeout = parseInt(process.env.PB_BATCH_TIMEOUT || '120')

    // ===========================================
    // EMAIL TEMPLATES
    // ===========================================
    const readTemplate = (path) => {
        if (!path) return ''
        try {
            return String($os.readFile(path))
        } catch (e) {
            console.log(`⚠️  Template not found: ${path}`)
            return ''
        }
    }

    if (process.env.PB_TPL_VERIFICATION_SUBJECT) {
        settings.meta.verificationTemplate.subject = process.env.PB_TPL_VERIFICATION_SUBJECT
    }
    if (process.env.PB_TPL_VERIFICATION_BODY) {
        const body = readTemplate(process.env.PB_TPL_VERIFICATION_BODY)
        if (body) settings.meta.verificationTemplate.body = body
    }

    if (process.env.PB_TPL_RESET_PWD_SUBJECT) {
        settings.meta.resetPasswordTemplate.subject = process.env.PB_TPL_RESET_PWD_SUBJECT
    }
    if (process.env.PB_TPL_RESET_PWD_BODY) {
        const body = readTemplate(process.env.PB_TPL_RESET_PWD_BODY)
        if (body) settings.meta.resetPasswordTemplate.body = body
    }

    if (process.env.PB_TPL_CONFIRM_EMAIL_SUBJECT) {
        settings.meta.confirmEmailChangeTemplate.subject = process.env.PB_TPL_CONFIRM_EMAIL_SUBJECT
    }
    if (process.env.PB_TPL_CONFIRM_EMAIL_BODY) {
        const body = readTemplate(process.env.PB_TPL_CONFIRM_EMAIL_BODY)
        if (body) settings.meta.confirmEmailChangeTemplate.body = body
    }

    if (process.env.PB_TPL_OTP_SUBJECT) {
        settings.meta.otpTemplate.subject = process.env.PB_TPL_OTP_SUBJECT
    }
    if (process.env.PB_TPL_OTP_BODY) {
        const body = readTemplate(process.env.PB_TPL_OTP_BODY)
        if (body) settings.meta.otpTemplate.body = body
    }

    // Save all settings
    app.save(settings)
    console.log(`✅ Settings configured: ${settings.meta.appName}`)
    console.log(`   SMTP:        ${settings.smtp.enabled ? 'enabled' : 'disabled'}`)
    console.log(`   S3:          ${settings.s3.enabled ? 'enabled' : 'disabled'}`)
    console.log(`   Backups S3:  ${settings.backups.s3.enabled ? 'enabled' : 'disabled'}`)
    console.log(`   Rate limits: ${settings.rateLimits.enabled ? 'enabled' : 'disabled'}`)
    console.log(`   Batch:       ${settings.batch.enabled ? 'enabled' : 'disabled'}`)

    // ===========================================
    // SUPERUSER
    // ===========================================
    const adminEmail = process.env.PB_ADMIN_EMAIL || ''
    const adminPassword = process.env.PB_ADMIN_PASSWORD || ''

    if (!adminEmail || !adminPassword) {
        console.log('⚠️  PB_ADMIN_EMAIL or PB_ADMIN_PASSWORD not set — skipping superuser creation')
    } else {
        const superusers = app.findCollectionByNameOrId('_superusers')
        try {
            app.findAuthRecordByEmail('_superusers', adminEmail)
            console.log('ℹ️  Superuser already exists — skipping')
        } catch (_) {
            const admin = new Record(superusers)
            admin.set('email', adminEmail)
            admin.set('password', adminPassword)
            app.save(admin)
            console.log(`✅ Superuser created: ${adminEmail}`)
        }
    }

    console.log('🎉 Initial settings migration completed!')
})