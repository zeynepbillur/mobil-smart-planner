const jwt = require("jsonwebtoken");
const ms = require("ms");
const Response = require("../utils/response");
const { UserModel } = require("../data");

// 🔑 TOKEN ÜRETİMİ
const createToken = async (userDoc) => {
  const payload = {
    sub: userDoc._id.toString(),
    role: userDoc.role,
    name: userDoc.name,
  };

  const expiresInStr = process.env.ACCESS_JWT_EXPIRES_IN || "15m";

  const token = jwt.sign(payload, process.env.JWT_SECRET_KEY, {
    algorithm: "HS512",
    expiresIn: expiresInStr,
  });

  return {
    token,
    expiresIn: ms(expiresInStr) / 1000,
  };
};

// 🔒 AUTH MIDDLEWARE
const authMiddleware = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return new Response(null, "Token bulunamadı").error401(res);
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET_KEY, {
      algorithms: ["HS512"],
    });

    const user = await UserModel.findById(decoded.sub).select(
      "_id name email role"
    );

    if (!user) {
      console.log("AUTH ERROR: User not found for sub:", decoded.sub);
      return new Response(null, "Kullanıcı bulunamadı").error401(res);
    }

    req.user = user; // 🔥 her yerde kullanılacak
    next();
  } catch (err) {
    console.error("JWT VERIFY ERROR:", err.message);
    if (err.name === 'TokenExpiredError') {
      console.log("Token expired at:", err.expiredAt);
    }
    return new Response(null, "Token geçersiz veya süresi dolmuş").error401(res);
  }
};

module.exports = {
  createToken,
  authMiddleware,
};
