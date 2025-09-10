const jwt = require("jsonwebtoken");

const verifyToken = (req, res, next) => {
      try {
            const authHeader = req.header("Authorization");
            if (!authHeader || !authHeader.startsWith("Bearer ")) {
                  return res.status(401).json({
                        message: "Akses ditolak, token tidak ditemukan atau format salah"
                  });
            }

            const token = authHeader.split(" ")[1];
            if (!token) {
                  return res.status(401).json({
                        message: "Token tidak ditemukan"
                  });
            }

            jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
                  if (err) {
                        return res.status(401).json({
                              message: "Token tidak valid atau sudah kedaluwarsa"
                        });
                  }

                  req.user = decoded; // Menyimpan payload JWT di req.user
                  next();
            });
      } catch (error) {
            res.status(500).json({
                  message: "Terjadi kesalahan dalam verifikasi token",
                  error: error.message
            });
      }
};

const isAdmin = (req, res, next) => {
      if (!req.user || !req.user.role) {
            return res.status(403).json({
                  message: "Akses ditolak, role tidak ditemukan dalam token"
            });
      }

      if (req.user.role !== "Admin") {
            return res.status(403).json({
                  message: "Akses ditolak, hanya admin yang bisa mengakses"
            });
      }

      next();
};

module.exports = {
      verifyToken,
      isAdmin
};