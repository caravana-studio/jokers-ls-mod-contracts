### Setting up the Local Environment

To get started follow these steps to set up your local environment.

1. Install Dojoup
    ```bash
    curl -L https://install.dojoengine.org | bash
    dojoup --version 1.0.0-alpha.13
    ```

2. Run the following commands in separate terminals:

    ```bash
    # Terminal 1
    make katana
    ```

    ```bash
    # Terminal 2
    make setup
    ```
### Setting up the Slot Environment

To get started follow these steps to set up your Slot environment.

Slot version `0.17.0`. 
You must be a member of either the `jokers-of-neon-prod` or `jokers-of-neon-testing` group. Executing this command will deploy to the production or testing environment, as applicable.

`make deploy-slot SCOPE=prod`

`make deploy-slot SCOPE=testing`

_We are using the same seed for both prod and testing. The accounts and systems will not change. The only things that will change are the URLs for Katana and Torii_
