## Mock Users

```

username: alice.johnson
password: securePass123

username: bob.smith
password: strongPwd456

username: charlie.brown
password: safePassword789

username: david.williams
password: pass1234word

username: emily.davis
password: mySecurePwd567

username: frank.miller
password: password7890

username: grace.taylor
password: safeAndStrongPwd

username: ivy.martinez
password: mySecurePassword

username: jack.turner
password: strongPwd4567

```

# Build & Run Locally

## Terminal

Navigate to the project folder and run the following command:

`swift run`

Once running you should see the following message:

`[ NOTICE ] Server starting on http://127.0.0.1:8080`

## Xcode

Open the project in Xcode:

`open Package.swift`

Set a custom working directory following [Vapor Xcode Guide](https://docs.vapor.codes/getting-started/xcode/).

Select "My Mac" target and click the play button (⌘ + R) to build and run your project.

Once running you should see the following message in the Xcode console:

`[ NOTICE ] Server starting on http://127.0.0.1:8080`

## Acessing local service from other devices (during development)

Inside the `main.swift` file, after the app is instantiated, add

```swift
app.http.server.configuration.hostname = "0.0.0.0"
```

This will allow the server to be discoverable by other devices in the same network as your computer (your iPhone, for instance). 

After doing that, on the client side where you do the API call, just change `127.0.0.1` or `localhost` to your computer's IP or hostname in the network.


