
// loginsq.h

#ifndef LOGIN_SQ_H
#define LOGIN_SQ_H

// Maximum length for username and password
#define MAX_USERNAME_LENGTH 256
#define MAX_PASSWORD_LENGTH 256

// Function declarations
void store_credentials(const char *username, const char *password);
int verify_credentials(const char *username, const char *password);

#endif // LOGIN_SQ_H