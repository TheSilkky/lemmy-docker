{
    hostname: "${LEMMY_HOSTNAME}"
    tls_enabled: true
    database: {
        uri: "${LEMMY_DATABASE_URI}"
    }
    pictrs: {
        url: "${LEMMY_PICTRS_URL}"
        api_key: "${LEMMY_PICTRS_API_KEY}"
    }
    email: {
        smtp_server: "${LEMMY_SMTP_SERVER}"
        smtp_login: "${LEMMY_SMTP_LOGIN}"
        smtp_password: "${LEMMY_SMTP_PASSWORD}"
        smtp_from_address: "${LEMMY_SMTP_FROM_ADDRESS}"
        tls_type: "${LEMMY_SMTP_TLS_TYPE}"
    }
    setup: {
        admin_username: "${LEMMY_SETUP_ADMIN_USERNAME}"
        admin_password: "${LEMMY_SETUP_ADMIN_PASSWORD}"
        admin_email: "${LEMMY_SETUP_ADMIN_EMAIL}"
        site_name: "${LEMMY_SETUP_SITE_NAME}"
    }
} 