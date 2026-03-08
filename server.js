const express = require("express")
const { exec } = require("child_process")
const fs = require("fs")
const archiver = require("archiver")
const rateLimit = require("express-rate-limit")

const app = express()
app.use(express.json())

/*
Rate limit protection
*/
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: "Too many requests, please try again later."
  }
})

app.use(limiter)

const PORT = process.env.PORT || 8080

/*
Cleanup old certificates
*/
setInterval(() => {

  const dir = "/app/certs"

  if (!fs.existsSync(dir)) return

  fs.readdir(dir,(err,files)=>{

    if (err) return

    files.forEach(file=>{

      const path = `${dir}/${file}`
      const stat = fs.statSync(path)

      const age = Date.now() - stat.mtimeMs

      if(age > 3600000){
        fs.unlinkSync(path)
      }

    })

  })

},600000)

/*
ROOT
*/
app.get("/", (req, res) => {
  res.send("ACME Engine API running")
})

/*
HEALTH CHECK (important for Railway)
*/
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" })
})

/*
STEP 1
Generate DNS challenge
*/
app.post("/generate", (req, res) => {

  const domain = req.body.domain
  const ca = req.body.ca || "letsencrypt"

  if (!domain) {
    return res.status(400).json({
      error: "Domain is required"
    })
  }

  if (!/^[a-zA-Z0-9.-]+$/.test(domain)) {
    return res.status(400).json({
      error: "Invalid domain format"
    })
  }

  if (!/^[a-zA-Z0-9._-]+$/.test(ca)) {
    return res.status(400).json({
      error: "Invalid CA format"
    })
  }

  console.log("Generating challenge for:", domain)

  exec(`bash /app/issue-cert.sh ${domain} ${ca}`, (error, stdout, stderr) => {

    if (error) {
      console.error("Generate error:", stderr)

      return res.status(500).json({
        error: stderr
      })
    }

    try {
      const result = JSON.parse(stdout.trim())

      if (result.error) {
        return res.status(500).json({
          error: result.error,
          raw_output: result.raw_output
        })
      }

      res.json({
        message: "DNS challenge generated",
        domain: result.domain,
        ca: ca,
        dns_record: result.dns_record,
        txt_value: result.txt_value
      })

    } catch (e) {
      console.error("Parse error:", e.message)
      res.status(500).json({
        error: "Failed to parse challenge output",
        output: stdout
      })
    }

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

  if (!/^[a-zA-Z0-9.-]+$/.test(domain)) {
    return res.status(400).json({
      error: "Invalid domain format"
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

/*
STEP 3
Download certificate ZIP
*/
app.get("/download/:domain", (req, res) => {

  const domain = req.params.domain

  if (!/^[a-zA-Z0-9.-]+$/.test(domain)) {
    return res.status(400).json({
      error: "Invalid domain format"
    })
  }

  const certPath = `/app/certs/${domain}.crt`
  const keyPath = `/app/certs/${domain}.key`

  if (!fs.existsSync(certPath) || !fs.existsSync(keyPath)) {
    return res.status(404).json({
      error: "Certificate not found"
    })
  }

  res.attachment(`${domain}-ssl.zip`)

  const archive = archiver("zip")

  archive.pipe(res)

  archive.file(certPath, { name: `${domain}.crt` })
  archive.file(keyPath, { name: `${domain}.key` })

  archive.finalize()

})

/*
START SERVER
*/
app.listen(PORT, "0.0.0.0", () => {
  console.log(`ACME Engine API running on port ${PORT}`)
})
