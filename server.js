const express = require("express");

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 8080;

app.get("/", (req, res) => {
  res.send("ACME Engine API running");
});

app.post("/generate", (req, res) => {
  const { domain } = req.body;

  if (!domain) {
    return res.status(400).json({ error: "Domain required" });
  }

  res.json({
    message: "ACME engine received request",
    domain: domain
  });
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`ACME Engine API running on port ${PORT}`);
});
