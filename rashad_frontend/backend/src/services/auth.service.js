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

  static async getUsers() {
    return await UserModel.find({}).select("-password");
  }

  static async updateUser(id, payload) {
    if (payload.password) {
      payload.password = await bcrypt.hash(payload.password, 12);
    }

    // Email benzersizliği kontrolü (eğer email değişiyorsa)
    if (payload.email) {
      const existingUser = await UserModel.findOne({ email: payload.email, _id: { $ne: id } });
      if (existingUser) {
        throw new Error("Bu email başka bir kullanıcı tarafından kullanılıyor");
      }
    }

    const user = await UserModel.findByIdAndUpdate(id, payload, { new: true });
    if (!user) {
      throw new Error("Kullanıcı bulunamadı");
    }
    return user;
  }
}

module.exports = AuthService;
