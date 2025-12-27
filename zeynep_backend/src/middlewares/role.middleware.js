const Response = require("../utils/response");

const checkRole = (role) => {
  return (req, res, next) => {
    if (!req.user || req.user.role !== role) {
      return new Response(null, "Yetkisiz erişim").error401(res);
    }
    next();
  };
};

module.exports = { checkRole };
