const AuthService = require("../services/auth.service");
const Response = require("../utils/response");
const { createToken } = require("../middlewares/auth.middleware");

class AuthController {
  static async register(req, res) {
    try {
      const user = await AuthService.register(req.body);
      return new Response(user, "Kayıt başarılı").created(res);
    } catch (error) {
      return new Response(null, error.message).error400(res);
    }
  }

  static async login(req, res) {
    try {
      const { email, password } = req.body;
      const user = await AuthService.login(email, password);

      const tokenData = await createToken(user);

      return new Response({
        token: tokenData.token,
        expiresIn: tokenData.expiresIn,
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          role: user.role,
        },
      }, "Giriş başarılı").success(res);

    } catch (error) {
      return new Response(null, error.message).error401(res);
    }
  }
}

module.exports = AuthController;
