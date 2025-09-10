const express = require('express');
const dns = require('dns');
const router = express.Router();

router.post('/check-email-domain', (req, res) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ valid: false, message: 'Email diperlukan' });

  const domain = email.split('@')[1];
  if (!domain) return res.status(400).json({ valid: false, message: 'Domain tidak ditemukan' });

  dns.resolveMx(domain, (err, addresses) => {
    if (err || !addresses || addresses.length === 0) {
      return res.json({ valid: false, message: 'Domain tidak aktif atau tidak ada MX record' });
    }
    return res.json({ valid: true });
  });
});

module.exports = router;
