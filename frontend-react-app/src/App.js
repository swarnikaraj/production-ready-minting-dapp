import { useState } from "react";
import "./App.css";

function App() {
  const [amount, setAmount] = useState(0);
  return (
    <div className="App">
      <div className="container">
        <div>
          <div className="flex">
            <button
              disabled={amount <= 0}
              onClick={() => setAmount(amount - 1)}
              className="bg-white text-black px-3"
            >
              -
            </button>
            <div className="px-4">{amount}</div>
            <button
              onClick={() => setAmount(amount + 1)}
              className="bg-white text-black px-3"
            >
              +
            </button>
          </div>
        </div>

        <div className="bg-[#aaa6a6] text-black px-4 py-2 mt-4">
          Minting unavailable
        </div>
      </div>
    </div>
  );
}

export default App;
