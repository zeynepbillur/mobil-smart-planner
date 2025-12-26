const express = require("express");
const { authMiddleware } = require("../middlewares/auth.middleware");
const { checkRole } = require("../middlewares/role.middleware");
const AuthController = require("../controllers/auth.controller");
const TaskController = require("../controllers/task.controller");
const ProgramController = require("../controllers/program.controller");

const router = express.Router();

// Auth route’ları (herkes erişebilir)
router.post("/register", AuthController.register);
router.post("/login", AuthController.login);

// Bundan sonrası auth gerektirir
router.use(authMiddleware);

// Task endpointleri
router.get("/tasks", TaskController.getTasks);
router.post("/tasks", TaskController.createTask);
router.put("/tasks/:id", TaskController.updateTask);
router.delete("/tasks/:id", TaskController.deleteTask);

// Program endpointleri (admin)
router.post("/programs", checkRole("admin"), ProgramController.createProgram);
router.post("/programs/approve-user", checkRole("admin"), ProgramController.approveUser);

// Program endpointleri (user/admin)
router.get("/programs", ProgramController.getPrograms);
router.get("/programs/:programId/tasks", ProgramController.getProgramTasks);

module.exports = router;
