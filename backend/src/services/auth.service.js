const { UserModel } = require("../data");
const bcrypt = require("bcryptjs");

class AuthService {
static async register(payload) {
    console.log("Register payload:", payload); // Test için
    const existingUser = await UserModel.findOne({ email: payload.email });
    if (existingUser) {
      throw new Error("Bu email zaten kayıtlı");
    }

    const hashedPassword = await bcrypt.hash(payload.password, 12);

    const user = await UserModel.create({
      ...payload,
      password: hashedPassword,
    });

    console.log("Created user:", user); // Test için
    return user;
}


  static async login(email, password) {
    const user = await UserModel.findOne({ email });
    if (!user) {
      throw new Error("Kullanıcı bulunamadı");
    }

    // 🔑 Şifre doğrulama
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      throw new Error("Şifre hatalı");
    }

    return user;
  }
}

module.exports = AuthService;
