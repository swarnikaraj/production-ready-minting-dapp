const express = require("express");
const dotenv = require("dotenv");
const { whitelist } = require("./whitelist");
dotenv.config();
const bodyParser = require("body-parser");
const app = express();

app.use(function (req, res, next) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
  next();
});

app.use(express.json());
app.use(bodyParser.urlencoded({ extended: true }));
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

app.get("/:address", async (req, res) => {
  try {
    const clamingAddress = req.params.address;

    const leafNodes1 = whitelist.map((i) => keccak256(i));
    console.log(leafNodes1);

    const merkleTreeWL = new MerkleTree(leafNodes1, keccak256, {
      sortPairs: true,
    });

    const rootWL = merkleTreeWL.getRoot();

    const leaf = keccak256(clamingAddress);
    const proofWL = merkleTreeWL.getHexProof(leaf);
    console.log(proofWL, "the proof");
    // Verify WL Merkle Proof
    const isValidWL = merkleTreeWL.verify(proofWL, leaf, rootWL);

    console.log(isValidWL, proofWL, "mai ander hu");

    return res.status(200).json({ isValidWL, proofWL });
  } catch (e) {
    return res.status(500).json({ status: "failed", message: e.message });
  }
});
app.get("/", async (req, res) => {
  return res.send("Welcome page");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, async function () {
  console.log("server is running on port:", PORT);
});
module.exports = app;
