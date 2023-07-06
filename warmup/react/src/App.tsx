import React, { useState, useEffect } from "react";
import { Button, Spinner } from "react-bootstrap";
import { send } from "./server_conn";

type AppState = "new" | "loading" | "ready";

function App() {
  const [state, setState] = useState<AppState>("new");
  const [title, setTitle] = useState<string>("");
  const [gameId, setGameId] = useState<string>("");

  useEffect(() => {
    // Fetch the title when the component mounts
    // send("/title", {}).then((data) => {
    //   setTitle(data.title);
    // });
  }, []);

  async function deep() {
    // Start the game when the button is clicked
    const deep = {
      a: 5,
      b: { c: false, d: [7, 6, 5] },
    };
    await send("/deep", deep).then((data) => {
      setGameId("doh");
      setState("ready");
    });
  }

  async function startGame() {
    // Start the game when the button is clicked
    setState("loading");
    await send("/start", {}).then((data) => {
      setGameId(data.game_id);
      setState("ready");
    });
  }

  return (
    <div className="container">
      <h1 className="text-center">{title}</h1>
      {state === "new" && (
        <div className="d-flex justify-content-center">
          <Button variant="success" onClick={startGame}>
            Start
          </Button>
        </div>
      )}
      <div className="d-flex justify-content-center">
        <Button variant="success" onClick={deep}>
          Deep
        </Button>
      </div>
      {state === "loading" && (
        <div className="d-flex justify-content-center">
          <Spinner animation="border" />
        </div>
      )}
      {state === "ready" && (
        <div className="d-flex justify-content-center">
          <p>Game ID: {gameId}</p>
        </div>
      )}
    </div>
  );
}

export default App;
