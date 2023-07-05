# Punting client

A simple demo React web application that talks to an HTTP server and displays information

## [.] Project setup

- A TypeScript React web application.
- Has the expected dependencies for a React web application.
- Use Bootstrap for styling.
- The web app has a modern minimalistic style using pastel colors, nicely sized components and good margin/padding between them.

## [server_conn] Server connection

Has helper functions to send HTTP requests to the server.
The server runs on localhost:8080.

- [send] Takes a $route and a $body.
    - Sends an HTTP request to the server on $route and with $body as the JSON body.
    - Set the request as no-cors.
    - Returns a promise that resolves to the JSON body of the response.

## [App] Application

The main user interface

- The application can be in three states: new, loading, and ready.
    - The application starts in the new state.

- [new state] Starting a new game.
    - Call [server_conn.send] to send a POST request to /title with an empty body.
    - The reply is a JSON object with a title.
      - Display the title.
    - Display a green button "Start" that starts the game.
      - When the button is clicked:
        - The application goes to the loading state.
        - Call [server_conn.send] to send a POST request to /start with an empty body.
        - The reply is a JSON object with a `game_id`.
        - The application goes to the ready state.
      
- [loading] Loading the game.
    - Display the title and a loading spinner.

- [ready] Display the game.
    - Display the title and the game_id.