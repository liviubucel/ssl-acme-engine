const express = require("express")
const { exec } = require("child_process")
const fs = require("fs")


setInterval(() => {

  const dir = "/app/certs"

  fs.readdir(dir,(err,files)=>{

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



const archiver = require("archiver")
const rateLimit = require("express-rate-limit")

const app = express()

app.use(express.json())

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minute
  max: 20, // max 20 requesturi
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    error: "Too many requests, please try again later."
  }
})

app.use(limiter)


const PORT = process.env.PORT || 8080

/*
 ROOT
*/
app.get("/", (req, res) => {
  res.send("ACME Engine API running")
})

/*
 HEALTH CHECK
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

  if (!domain) {
    return res.status(400).json({
      error: "Domain is required"
    })
  }

  console.log("Request received for domain:", domain)

  exec(`bash /app/issue-cert.sh ${domain}`, (error, stdout, stderr) => {

    if (error) {
      console.error("Generate error:", stderr)

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

/*
 STEP 3
 Download certificate ZIP
*/
app.get("/download/:domain", (req, res) => {

  const domain = req.params.domain

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
