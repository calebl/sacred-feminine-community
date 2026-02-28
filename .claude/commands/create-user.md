# /create-user

Create a new user account via the `users:create` rake task.

## Usage

```
/create-user                                          # Prompted for all details
/create-user admin jane@example.com "Jane Doe"        # Quick: role email name
/create-user --email=jane@example.com --name="Jane"   # Explicit flags
```

## Process

1. **Collect user details** from the arguments or by asking the user
2. **Generate a secure password** (unless one was provided)
3. **Run the rake task** non-interactively
4. **Report the result** back to the user

## Required Fields

| Field    | Default    | Notes                          |
|----------|------------|--------------------------------|
| email    | —          | Must be unique                 |
| name     | —          | Required                       |
| password | (generate) | Min 6 chars; auto-generated if omitted |
| role     | attendee   | `attendee` or `admin`          |
| city     | —          | Optional                       |
| country  | —          | Optional                       |

## Instructions

When the user invokes this command:

1. **Parse any arguments provided.** Accept positional args as `role email name` or `--key=value` flags. If any required field (email, name) is missing, ask the user using the AskUserQuestion tool. Ask all missing fields in a single question batch.

2. **Generate a password** if none was provided. Use the Bash tool to run:
   ```
   openssl rand -base64 12
   ```
   This produces a 16-character random password.

3. **Run the rake task** using the Bash tool:
   ```
   bundle exec rake users:create -- --email=EMAIL --name="NAME" --password=PASS --role=ROLE --city=CITY --country=COUNTRY
   ```
   Omit `--city` and `--country` flags if not provided. Quote values that contain spaces.

4. **Report the result.** On success, show the created user details and the generated password (if auto-generated) so the user can share credentials. On failure, show the error messages from the rake task output.

## Important

- Never store or log passwords in files. Only display them once in the conversation.
- Always quote the `--name` and `--password` values in case they contain special characters.
- The rake task must be run from the project root directory.
- If the user wants to create multiple users, run the rake task once per user.
