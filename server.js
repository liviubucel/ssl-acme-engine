const express = require("express")
const { exec } = require("child_process")

const app = express()

app.use(express.json())

const PORT = process.env.PORT || 8080

app.get("/", (req, res) => {
  res.send("ACME Engine API running")
})

app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" })
})

/*
 STEP 1
 Generate DNS challenge
*/
app.post("/generate", (req, res) => {

  const domain = req.body.domain

  if (!domain) {
    return res.status(400).json({
      error: "Domain is required"
    })
  }

  console.log("Request received for domain:", domain)

  exec(`bash /app/issue-cert.sh ${domain}`, (error, stdout, stderr) => {

    if (error) {
      console.error("Error:", stderr)

      return res.status(500).json({
        error: stderr
      })
    }

    res.json({
      message: "DNS challenge generated",
      domain: domain,
      output: stdout
    })

  })

})

/*
 STEP 2
 Verify DNS and issue certificate
*/
app.post("/verify", (req, res) => {

  const domain = req.body.domain

  if (!domain) {
    return res.status(400).json({
      error: "Domain is required"
    })
  }

  console.log("Verifying domain:", domain)

  exec(`bash /app/renew.sh ${domain}`, (error, stdout, stderr) => {

    if (error) {
      console.error("Verify error:", stderr)

      return res.status(500).json({
        error: stderr
      })
    }

    res.json({
      message: "Certificate issued successfully",
      domain: domain,
      output: stdout
    })

  })

})

app.listen(PORT, "0.0.0.0", () => {
  console.log(`ACME Engine API running on port ${PORT}`)
})
