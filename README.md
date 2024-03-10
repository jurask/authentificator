# OTP keychain
OTP authentificator for Garmin devices

## Features
- Time based (TOTP) and counter based (HOTP) keys
- Up to 5 accounts (unilimited impossible due to broken CIQ settings)
- Keys are stored in hidden storage not visible through Connect app
- Live glance on supported devices

## Instructions
To add key/account use Add item option in app settings
- Name - account/key name
- Type - totp - time based code, that expires in certain period, HOTP - counter based code, that expires when user uses it
- Key - authentificator key in base32 encoding (string containing numbers and letters)
- Timeout - when used in TOTP mode, this is the timeout period for which the key is valid (typically 30 seconds)
- Counter value - when used in HOTP mode, this field contains the current value of the counter, you can modify the counter by Next code/previous code commands in the widget view
- Number of digits to display - length of the authentification code (typically 6)

Once the key is entered and the application is started, the key will be moved to internal storage leaving #hidden ... in the settings, if you want to replace the key, just enter new key in this field and start the app again.

By default, the code for the first account will be displayed in the widget glance view, you can disable this behaviour in settings.
