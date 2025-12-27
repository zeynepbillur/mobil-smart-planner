require("dotenv").config();
const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");

const UserSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true },
    password: { type: String, required: true },
    role: { type: String, enum: ["admin", "user"], default: "user" }
  },
  { timestamps: true }
);

const User = mongoose.model("User", UserSchema);

async function addUsers() {
  try {
    // MongoDB'ye bağlan
    await mongoose.connect(process.env.MONGO_URI);
    console.log("MongoDB bağlantısı başarılı");

    // Şifreleri hashle
    const hashedPassword = await bcrypt.hash("password", 12);

    // Kullanıcıları oluştur
    const users = [
      {
        name: "Zeynep Aslan",
        email: "zeynep.aslan@gmail.com",
        password: hashedPassword,
        role: "user"
      },
      {
        name: "Admin",
        email: "admin@test.com",
        password: hashedPassword,
        role: "admin"
      }
    ];

    // Mevcut kullanıcıları kontrol et ve ekle
    for (const userData of users) {
      const existingUser = await User.findOne({ email: userData.email });
      
      if (existingUser) {
        console.log(`✗ ${userData.email} zaten mevcut`);
      } else {
        await User.create(userData);
        console.log(`✓ ${userData.email} eklendi (role: ${userData.role})`);
      }
    }

    console.log("\nİşlem tamamlandı!");
    process.exit(0);
  } catch (error) {
    console.error("Hata:", error.message);
    process.exit(1);
  }
}

addUsers();
