const connectDB = require("./connection");

const UserModel = require("./models/User.model");
const TaskModel = require("./models/Task.model");
const CategoryModel = require("./models/Category.model");
const ProgramModel = require("./models/Program.model");

module.exports = {
  connectDB,
  UserModel,
  TaskModel,
  CategoryModel,
  ProgramModel
};
