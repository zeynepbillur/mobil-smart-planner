class User {
  constructor({ id, name, email, role = "user" }) {
    this.id = id;
    this.name = name;
    this.email = email;
    this.role = role;
  }

  isAdmin() {
    return this.role === "admin";
  }
}

module.exports = User;
