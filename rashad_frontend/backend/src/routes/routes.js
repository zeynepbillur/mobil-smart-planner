const express = require("express");
const { authMiddleware } = require("../middlewares/auth.middleware");
const { checkRole } = require("../middlewares/role.middleware");
const AuthController = require("../controllers/auth.controller");
const TaskController = require("../controllers/task.controller");
const ProgramController = require("../controllers/program.controller");
const AIController = require("../controllers/ai.controller");

const router = express.Router();

// Auth route’ları (herkes erişebilir)
router.post("/register", AuthController.register);
router.post("/login", AuthController.login);
router.get("/users", authMiddleware, AuthController.getUsers);
router.put("/users/:id", authMiddleware, AuthController.updateUser);

// Bundan sonrası auth gerektirir
router.use(authMiddleware);

// Task endpointleri
router.get("/tasks", TaskController.getTasks);
router.get("/tasks/all", checkRole("admin"), TaskController.getAllTasks);
router.get("/tasks/user/:userId", checkRole("admin"), TaskController.getUserTasks);
router.post("/tasks", TaskController.createTask);
router.put("/tasks/:id", TaskController.updateTask);
router.delete("/tasks/:id", TaskController.deleteTask);

// Program endpointleri (admin)
router.post("/programs", checkRole("admin"), ProgramController.createProgram);
router.put("/programs/:id", checkRole("admin"), ProgramController.updateProgram);
router.delete("/programs/:id", checkRole("admin"), ProgramController.deleteProgram);
router.post("/programs/approve-user", checkRole("admin"), ProgramController.approveUser);

// Program endpointleri (user/admin)
router.get("/programs", ProgramController.getPrograms);
router.post("/programs/join", ProgramController.joinProgram);
router.get("/programs/:programId/tasks", ProgramController.getProgramTasks);

router.post("/ai/chat", AIController.chat);


module.exports = router;
