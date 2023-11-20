## Login with Wallet Next

Here we implement the login with wallet flow using the [Next.js](https://nextjs.org/) framework.
## Setup

To run the project, first clone this repository, and then run one of the following commands to install the dependencies:

```bash
npm install
# or
yarn install
```

Next, you need to create a `.env.local` file and add the `ADMIN_PRIVATE_KEY` variable to it with the private key of the wallet you want to use as the admin wallet to generate and verify payloads. Your file should use something like the following:

```.env
ADMIN_PRIVATE_KEY=...(You can find the private key in your Metamask in the three dots and enter in your password to reveal it)
```

Finally, you can run the project with one of the following commands:

```bash
npm run dev
# or
yarn dev
```

Now, you can navigate to [http://localhost:3000](http://localhost:3000) to visit the client side page where you can connect a wallet, sign-in with ethereum and view the payload, and use the payload to authenticate with the backend.

<!-- [![Actions Status](https://github.com/tweether-protocol/twitter-cl-ea/workflows/yarn/badge.svg)](https://github.com/tweether-protocol/reddit-cl-ea/actions?query=workflow%3Ayarn) -->
[![Percentage of issues still open](http://isitmaintained.com/badge/open/tweether-protocol/twitter-cl-ea.svg)](http://isitmaintained.com/project/tweether-protocol/twitter-cl-ea "Percentage of issues still open")

# Twitter Chainlink External Adapter

*NOTE* Their are a number of TODOs to make this repo more robust. Its very elementary at the moment, only allowing you to tweet from you smart contract.

The template allows a user to interact with the Twitter API. This uses the [Twitter API](https://developer.twitter.com/en/portal/projects-and-apps)

## Quickstart

After you [create an app in Twitter](https://developer.twitter.com/en/portal/projects-and-apps) you'll need 4 environment variables and to get approved. Approval will take a few days. Here are the environment variables.
```
TWITTER_CONSUMER_KEY
TWITTER_CONSUMER_SECRET
TWITTER_ACCESS_TOKEN_KEY
TWITTER_ACCESS_TOKEN_SECRET
```
You'll get the top two in your Twitter App, and the bottom two you'll have to generate a token in your [projects page](https://developer.twitter.com/en/portal/projects-and-apps):

```bash
git clone https://github.com/tweether-protocol/twitter-cl-ea
cd twitter-cl-ea
yarn
yarn start
```

See [Install Locally](#install-locally) for a quickstart

## Input Params

- `endpoint`: The Twitter API endpoint, this defaults to updating your status. 
-  `status`: The status you want to set

Right now you can only post your status. Please make a PR to add functionality :)

## Sample cURL

```bash
curl -X POST -H "content-type:application/json" "http://localhost:8080/" --data '{ "id": 0, "data": {"status":"Chainlink is amazing"}}'
```

## Output

```json
{
  jobRunID: 0,
  data: { result: 1315380402618499000 },
  result: 1315380402618499000,
  statusCode: 200
}
```

This is the ID of your tweet.

## Install Locally

Install dependencies:

```bash
yarn
```

### Test

Run the local tests:

```bash
yarn test
```

Natively run the application (defaults to port 8080):

### Run

```bash
yarn start
```

## Call the external adapter/API server

```bash
curl -X POST -H "content-type:application/json" "http://localhost:8080/" --data '{ "id": 0, "data": {"status":"Chainlink is amazing"}}'
```

## Docker

If you wish to use Docker to run the adapter, you can build the image by running the following command:

```bash
docker build . -t external-adapter
```

Then run it with:

```bash
docker run -p 8080:8080 -it external-adapter:latest
```

## Serverless hosts

After [installing locally](#install-locally):

### Create the zip

```bash
zip -r external-adapter.zip .
```

### Install to AWS Lambda

- In Lambda Functions, create function
- On the Create function page:
  - Give the function a name
  - Use Node.js 12.x for the runtime
  - Choose an existing role or create a new one
  - Click Create Function
- Under Function code, select "Upload a .zip file" from the Code entry type drop-down
- Click Upload and select the `external-adapter.zip` file
- Handler:
    - index.handler for REST API Gateways
    - index.handlerv2 for HTTP API Gateways
- Add the environment variable (repeat for all environment variables):
  - Key: API_KEY
  - Value: Your_API_key
- Save

#### To Set Up an API Gateway (HTTP API)

If using a HTTP API Gateway, Lambda's built-in Test will fail, but you will be able to externally call the function successfully.

- Click Add Trigger
- Select API Gateway in Trigger configuration
- Under API, click Create an API
- Choose HTTP API
- Select the security for the API
- Click Add

#### To Set Up an API Gateway (REST API)

If using a REST API Gateway, you will need to disable the Lambda proxy integration for Lambda-based adapter to function.

- Click Add Trigger
- Select API Gateway in Trigger configuration
- Under API, click Create an API
- Choose REST API
- Select the security for the API
- Click Add
- Click the API Gateway trigger
- Click the name of the trigger (this is a link, a new window opens)
- Click Integration Request
- Uncheck Use Lamba Proxy integration
- Click OK on the two dialogs
- Return to your function
- Remove the API Gateway and Save
- Click Add Trigger and use the same API Gateway
- Select the deployment stage and security
- Click Add

### Install to GCP

- In Functions, create a new function, choose to ZIP upload
- Click Browse and select the `external-adapter.zip` file
- Select a Storage Bucket to keep the zip in
- Function to execute: gcpservice
- Click More, Add variable (repeat for all environment variables)
  - NAME: API_KEY
  - VALUE: Your_API_key

## Building the project & running tests

_Note: This repository is a [Foundry](https://book.getfoundry.sh/) project, so make sure that [Foundry is installed](https://book.getfoundry.sh/getting-started/installation) locally._

To make sure that Foundry is up to date and install dependencies, run the following command:

```bash
foundryup && forge install
```

Once the dependencies are installed, tests can be run:

```bash
forge test
```

## Deploying Contracts

To deploy *ANY* contract, with no requirements, use thirdweb Deploy:

```bash
npx thirdweb deploy
```

1. Deploy the implementation contract, `TokenBoundAccount` as this will be needed as a constructor parameter for the factory.
2. Deploy the factory contract `TokenBoundAccountFactory`

In both cases, set the `EntryPoint` contract address as `0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789`.
This address is the same on all chains it is deployed to.

## Join our Discord!

For any questions or suggestions, join our discord at [https://discord.gg/thirdweb](https://discord.gg/thirdweb).
